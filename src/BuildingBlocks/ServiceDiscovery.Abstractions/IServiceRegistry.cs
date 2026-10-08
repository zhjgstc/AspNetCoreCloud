namespace AspNetCoreCloud.ServiceDiscovery;

/// <summary>
/// 服务注册：把自己的地址写进注册中心，并在停机时摘除。
/// </summary>
public interface IServiceRegistry
{
    Task RegisterAsync(ServiceRegistration registration, CancellationToken ct = default);

    Task DeregisterAsync(ServiceRegistration registration, CancellationToken ct = default);
}
