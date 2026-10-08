namespace AspNetCoreCloud.ServiceDiscovery;

/// <summary>
/// 一个可被发现的服务实例（端点）。
///
/// 关键设计：这个类型里**没有任何注册中心的概念**（没有 Nacos / Consul / K8s 的痕迹）。
/// 业务代码只认服务名 + 地址，换注册中心时本类型不需要改动。
/// </summary>
/// <param name="ServiceName">逻辑服务名，如 product / order / auth</param>
/// <param name="InstanceId">实例唯一标识，用于日志与负载均衡追踪</param>
/// <param name="Address">完整基址，如 http://192.168.1.10:10300</param>
public sealed record ServiceEndpoint(string ServiceName, string InstanceId, string Address)
{
    public bool IsHttps => Address.StartsWith("https://", StringComparison.OrdinalIgnoreCase);

    /// <summary>实例元数据（版本、区域等），注册中心可缺省返回空</summary>
    public IReadOnlyDictionary<string, string> Metadata { get; init; } = new Dictionary<string, string>();

    public override string ToString() => $"{ServiceName}[{InstanceId}] {Address}";
}
