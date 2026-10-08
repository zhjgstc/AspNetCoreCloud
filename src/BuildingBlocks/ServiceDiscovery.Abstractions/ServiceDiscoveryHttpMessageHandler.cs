using Microsoft.Extensions.Logging;

namespace AspNetCoreCloud.ServiceDiscovery;

/// <summary>
/// 挂在 HttpClient 管道上的解析处理器：每次发请求前，把目标地址解析成真实实例地址。
///
/// 为什么要放在管道里而不是构造 HttpClient 时固定基址：
///   实例列表会随扩缩容、上下线变化，必须在**每次请求**时重新解析，
///   否则服务下线后客户端还拿着死地址。
/// </summary>
public sealed class ServiceDiscoveryHttpMessageHandler : DelegatingHandler
{
    private readonly IServiceDiscovery _discovery;
    private readonly string _serviceName;
    private readonly ILogger<ServiceDiscoveryHttpMessageHandler> _logger;

    public ServiceDiscoveryHttpMessageHandler(
        IServiceDiscovery discovery,
        string serviceName,
        ILogger<ServiceDiscoveryHttpMessageHandler> logger)
    {
        _discovery = discovery;
        _serviceName = serviceName;
        _logger = logger;
    }

    protected override async Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken ct)
    {
        var endpoints = await _discovery.ResolveAsync(_serviceName, ct);

        if (endpoints.Count == 0)
        {
            throw new ServiceDiscoveryException($"服务 {_serviceName} 当前没有可用实例");
        }

        // 随机挑一个 —— 客户端侧最简负载均衡（非 K8s 场景没有 kube-proxy 帮我们做这件事）
        var endpoint = endpoints[Random.Shared.Next(endpoints.Count)];

        request.RequestUri = RewriteUri(endpoint, request.RequestUri);

        // 便于演示/排障：下游能知道自己是被哪个实例服务的
        request.Headers.TryAddWithoutValidation("X-Downstream-Instance", endpoint.InstanceId);

        _logger.LogDebug("服务调用 {Service} -> {Endpoint}", _serviceName, endpoint.Address);

        return await base.SendAsync(request, ct);
    }

    internal static Uri RewriteUri(ServiceEndpoint endpoint, Uri? original)
    {
        var baseUri = new Uri(endpoint.Address.TrimEnd('/') + "/");

        if (original is null)
        {
            return baseUri;
        }

        // 相对 Uri 取 PathAndQuery 会抛异常，所以这里分开处理
        var pathAndQuery = original.IsAbsoluteUri
            ? original.PathAndQuery
            : original.OriginalString;

        return new Uri(baseUri, pathAndQuery.TrimStart('/'));
    }
}
