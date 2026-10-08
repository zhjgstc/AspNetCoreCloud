using Microsoft.Extensions.Logging;
using Nacos.V2;
using Nacos.V2.Naming.Dtos;

namespace AspNetCoreCloud.ServiceDiscovery.Nacos;

/// <summary>
/// 把本实例注册到 Nacos，停机时摘除。
/// </summary>
public sealed class NacosServiceRegistry : IServiceRegistry
{
    private readonly INacosNamingService _naming;
    private readonly NacosDiscoveryOptions _options;
    private readonly ILogger<NacosServiceRegistry> _logger;

    public NacosServiceRegistry(
        INacosNamingService naming,
        NacosDiscoveryOptions options,
        ILogger<NacosServiceRegistry> logger)
    {
        _naming = naming;
        _options = options;
        _logger = logger;
    }

    public async Task RegisterAsync(ServiceRegistration registration, CancellationToken ct = default)
    {
        var instance = ToInstance(registration);

        _logger.LogInformation(
            "注册到 Nacos：{Service} -> {Address}（group={Group}, cluster={Cluster}）",
            registration.ServiceName, registration.Address, _options.GroupName, _options.ClusterName);

        await _naming.RegisterInstance(registration.ServiceName, _options.GroupName, instance);
    }

    public async Task DeregisterAsync(ServiceRegistration registration, CancellationToken ct = default)
    {
        _logger.LogInformation("从 Nacos 摘除：{Service} -> {Address}", registration.ServiceName, registration.Address);
        await _naming.DeregisterInstance(registration.ServiceName, _options.GroupName, ToInstance(registration));
    }

    private Instance ToInstance(ServiceRegistration registration) => new()
    {
        InstanceId = registration.InstanceId,
        ServiceName = registration.ServiceName,
        Ip = registration.Ip,
        Port = registration.Port,
        ClusterName = _options.ClusterName,
        Weight = _options.Weight,
        Ephemeral = true,   // 临时实例：靠客户端心跳保活，进程没了自动摘除
        Enabled = true,
        Healthy = true
    };
}
