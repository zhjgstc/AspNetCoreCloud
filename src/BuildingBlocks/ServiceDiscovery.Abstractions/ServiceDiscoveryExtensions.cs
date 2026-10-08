namespace AspNetCoreCloud.ServiceDiscovery;

/// <summary>IServiceDiscovery 的便捷扩展。</summary>
public static class ServiceDiscoveryExtensions
{
    /// <summary>随机取一个可用实例；没有可用实例时抛 <see cref="ServiceDiscoveryException"/>。</summary>
    public static async Task<ServiceEndpoint> ResolveOneAsync(
        this IServiceDiscovery discovery,
        string serviceName,
        CancellationToken ct = default)
    {
        var endpoints = await discovery.ResolveAsync(serviceName, ct);

        if (endpoints.Count == 0)
        {
            throw new ServiceDiscoveryException($"服务 {serviceName} 当前没有可用实例");
        }

        return endpoints[Random.Shared.Next(endpoints.Count)];
    }
}
