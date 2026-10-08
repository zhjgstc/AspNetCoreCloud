namespace AspNetCoreCloud.ServiceDiscovery;

/// <summary>
/// 本实例要注册到注册中心的信息。
/// </summary>
/// <param name="ServiceName">逻辑服务名</param>
/// <param name="InstanceId">实例唯一标识（同一服务多实例时用于区分）</param>
/// <param name="Ip">对外可访问的 IP（容器场景最容易错的一项）</param>
/// <param name="Port">对外可访问的端口</param>
/// <param name="Scheme">http / https</param>
public sealed record ServiceRegistration(
    string ServiceName,
    string InstanceId,
    string Ip,
    int Port,
    string Scheme = "http")
{
    public string Address => $"{Scheme}://{Ip}:{Port}";
}
