using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;

namespace AspNetCoreCloud.ServiceDiscovery;

public static class ServiceDiscoveryServiceCollectionExtensions
{
    /// <summary>
    /// 注册一个「按逻辑服务名寻址」的 HttpClient。
    ///
    /// 用法：<c>builder.Services.AddServiceDiscoveryHttpClient("product");</c>
    /// 之后在业务代码里 <c>httpClientFactory.CreateClient("product")</c>，
    /// 用相对路径 <c>"api/product/test"</c> 调用即可，地址解析由管道自动完成。
    /// </summary>
    /// <param name="services">服务容器</param>
    /// <param name="name">HttpClient 的逻辑名</param>
    /// <param name="serviceName">注册中心里的服务名，缺省与 <paramref name="name"/> 相同</param>
    public static IHttpClientBuilder AddServiceDiscoveryHttpClient(
        this IServiceCollection services,
        string name,
        string? serviceName = null)
    {
        var target = serviceName ?? name;

        var httpClientBuilder = services.AddHttpClient(name, client =>
        {
            // 占位基址：真正的地址在 ServiceDiscoveryHttpMessageHandler 里被改写。
            // 用服务名做主机名，解析失败时错误信息里能直接看到是哪个服务出了问题。
            client.BaseAddress = PlaceholderUri(target);
        });

        httpClientBuilder.AddHttpMessageHandler(sp => new ServiceDiscoveryHttpMessageHandler(
            sp.GetRequiredService<IServiceDiscovery>(),
            target,
            sp.GetRequiredService<ILogger<ServiceDiscoveryHttpMessageHandler>>()));

        return httpClientBuilder;
    }

    private static Uri PlaceholderUri(string serviceName)
        => Uri.TryCreate($"http://{serviceName}", UriKind.Absolute, out var uri)
            ? uri
            : new Uri("http://localhost");
}
