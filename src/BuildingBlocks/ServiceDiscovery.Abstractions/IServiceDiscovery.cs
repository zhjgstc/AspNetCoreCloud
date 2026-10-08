namespace AspNetCoreCloud.ServiceDiscovery;

/// <summary>
/// 服务发现：按逻辑服务名拿可用实例列表。
///
/// 这是整个架构里最关键的抽象 —— 非 K8s 走 Nacos，K8s 走 Service DNS，
/// 业务代码始终只写 <c>discovery.ResolveAsync("product")</c>。
/// </summary>
public interface IServiceDiscovery
{
    /// <summary>
    /// 返回该服务当前所有健康实例。无可用实例时返回空列表（不抛异常，交给调用方决定降级策略）。
    /// </summary>
    Task<IReadOnlyList<ServiceEndpoint>> ResolveAsync(string serviceName, CancellationToken ct = default);
}
