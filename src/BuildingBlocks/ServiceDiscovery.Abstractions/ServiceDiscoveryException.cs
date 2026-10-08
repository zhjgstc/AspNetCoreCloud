namespace AspNetCoreCloud.ServiceDiscovery;

/// <summary>服务发现过程失败时抛出（注册中心不可达且本地缓存也没数据等场景）。</summary>
public sealed class ServiceDiscoveryException : Exception
{
    public ServiceDiscoveryException(string message) : base(message) { }

    public ServiceDiscoveryException(string message, Exception innerException) : base(message, innerException) { }
}
