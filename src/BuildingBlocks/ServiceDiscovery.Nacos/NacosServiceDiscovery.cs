using Microsoft.Extensions.Logging;
using Nacos.V2;
using Nacos.V2.Naming.Dtos;

namespace AspNetCoreCloud.ServiceDiscovery.Nacos;

/// <summary>
/// 从 Nacos 查可用实例。
///
/// 实现要点：
/// 1. 用 <c>SelectInstances(..., subscribe: true)</c> —— 除了拿结果，还会让 SDK 自己
///    维护订阅与本地缓存，这样 Nacos 短暂不可用时仍能靠缓存继续调用。
/// 2. 额外注册一个 IEventListener，纯粹为了把「实例变更」打进日志，
///    演示时能直观看到扩缩容/下线被感知。
/// </summary>
public sealed class NacosServiceDiscovery : IServiceDiscovery, IEventListener
{
    private readonly INacosNamingService _naming;
    private readonly NacosDiscoveryOptions _options;
    private readonly ILogger<NacosServiceDiscovery> _logger;
    private readonly object _sync = new();
    private readonly HashSet<string> _subscribed = new(StringComparer.Ordinal);

    public NacosServiceDiscovery(
        INacosNamingService naming,
        NacosDiscoveryOptions options,
        ILogger<NacosServiceDiscovery> logger)
    {
        _naming = naming;
        _options = options;
        _logger = logger;
    }

    public async Task<IReadOnlyList<ServiceEndpoint>> ResolveAsync(string serviceName, CancellationToken ct = default)
    {
        EnsureSubscribed(serviceName);

        var instances = await _naming.SelectInstances(serviceName, _options.GroupName, healthy: true, subscribe: true);

        var endpoints = instances
            .Where(i => i.Enabled)
            .Select(i => ToEndpoint(serviceName, i))
            .ToList();

        _logger.LogTrace("发现 {Service} 的 {Count} 个健康实例", serviceName, endpoints.Count);

        return endpoints;
    }

    public Task OnEvent(IEvent evt)
    {
        // 注意 global:: —— 本工程命名空间结尾也叫 Nacos，不限定会解析到自己头上
        if (evt is global::Nacos.V2.Naming.Event.InstancesChangeEvent change)
        {
            _logger.LogInformation(
                "实例变更：{Service} 现有 {Count} 个实例",
                change.ServiceName, change.Hosts?.Count ?? 0);
        }
        else
        {
            _logger.LogDebug("收到 Nacos 事件：{Event}", evt.GetType().Name);
        }

        return Task.CompletedTask;
    }

    private void EnsureSubscribed(string serviceName)
    {
        lock (_sync)
        {
            if (!_subscribed.Add(serviceName))
            {
                return;
            }
        }

        // 订阅失败不影响主流程（缓存 + 每次查询仍可用），所以放后台跑
        _ = Task.Run(async () =>
        {
            try
            {
                await _naming.Subscribe(serviceName, _options.GroupName, this);
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "订阅 {Service} 的实例变更失败，将退化为每次查询", serviceName);
                lock (_sync)
                {
                    _subscribed.Remove(serviceName);
                }
            }
        });
    }

    private ServiceEndpoint ToEndpoint(string serviceName, Instance instance) => new(
        serviceName,
        string.IsNullOrWhiteSpace(instance.InstanceId) ? $"{instance.Ip}:{instance.Port}" : instance.InstanceId,
        $"{_options.Scheme}://{instance.Ip}:{instance.Port}");
}
