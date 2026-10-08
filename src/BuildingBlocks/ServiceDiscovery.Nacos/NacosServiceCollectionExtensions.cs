using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Nacos.V2.DependencyInjection;
using Nacos.V2;

namespace AspNetCoreCloud.ServiceDiscovery.Nacos;

public static class NacosServiceCollectionExtensions
{
    /// <summary>
    /// 接入 Nacos 的注册与发现。
    ///
    /// 这是全仓库**唯一**接触 nacos-sdk-csharp 的地方。业务服务只依赖
    /// <see cref="IServiceDiscovery"/> / <see cref="IServiceRegistry"/>，
    /// 将来换成别的注册中心，业务代码一行不用改。
    /// </summary>
    public static IServiceCollection AddNacosServiceDiscovery(
        this IServiceCollection services,
        IConfiguration configuration,
        string sectionName = NacosDiscoveryOptions.SectionName)
    {
        var options = configuration.GetSection(sectionName).Get<NacosDiscoveryOptions>()
                      ?? new NacosDiscoveryOptions();

        // 服务名以 Nacos:ServiceName 为准；没配就回退到通用的 Service:Name。
        // 这样「我是谁」只有 Service:Name 一个真相来源，避免两处配置漂移。
        if (string.IsNullOrWhiteSpace(options.ServiceName))
        {
            options.ServiceName = configuration["Service:Name"] ?? string.Empty;
        }

        if (string.IsNullOrWhiteSpace(options.ServiceName))
        {
            throw new InvalidOperationException(
                $"缺少服务名配置：请设置 {sectionName}:ServiceName 或 Service:Name。");
        }

        // 端口推导刻意不在这里做：配置里的 "Urls" 只是 Kestrel 的默认值来源之一，
        // 命令行 --urls、ASPNETCORE_URLS 都可能覆盖它，提前取值会与实际监听漂移
        // （实测过：第二实例用 --urls 10301 启动，却注册成了配置里的 10300，
        //   与第一个实例同 ip:port，被注册中心当成同一个实例）。
        // 真正的端口在 NacosRegistrationHostedService 里从 Kestrel 实际监听地址推导，
        // Nacos:Port 仅在需要覆盖时使用。

        if (options.ServerAddresses.Count == 0)
        {
            // 没配就退回本机默认地址：demo 能直接跑起来，但不该在生产里靠这个兜底
            options.ServerAddresses.Add("http://localhost:8848");
        }

        services.AddSingleton(options);

        services.AddNacosV2Naming(sdk =>
        {
            sdk.ServerAddresses = options.ServerAddresses;
            sdk.Namespace = options.Namespace;
            sdk.UserName = options.UserName;
            sdk.Password = options.Password;
            // 实测：SDK 1.3.10 的 gRPC 与 Nacos 2.5.4 握手失败，默认走 HTTP
            sdk.NamingUseRpc = options.NamingUseRpc;
            sdk.DefaultTimeOut = options.DefaultTimeOut;
        }, null);

        services.AddSingleton<IServiceRegistry, NacosServiceRegistry>();
        services.AddSingleton<IServiceDiscovery, NacosServiceDiscovery>();
        services.AddHostedService<NacosRegistrationHostedService>();

        return services;
    }
}
