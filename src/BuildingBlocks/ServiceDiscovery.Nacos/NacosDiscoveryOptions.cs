namespace AspNetCoreCloud.ServiceDiscovery.Nacos;

/// <summary>
/// Nacos 注册发现的配置（绑定 appsettings.json 的 "Nacos" 段）。
///
/// 敏感项（Password）不要写进配置文件，用环境变量覆盖：
///   Nacos__Password=xxx        （冒号在环境变量里写成双下划线）
/// </summary>
public sealed class NacosDiscoveryOptions
{
    public const string SectionName = "Nacos";

    /// <summary>Nacos 服务地址，如 http://nacos:8848</summary>
    public List<string> ServerAddresses { get; set; } = new() { "http://localhost:8848" };

    /// <summary>命名空间 ID，空字符串表示 public</summary>
    public string Namespace { get; set; } = string.Empty;

    public string UserName { get; set; } = "nacos";

    public string Password { get; set; } = string.Empty;

    public string GroupName { get; set; } = "DEFAULT_GROUP";

    public string ClusterName { get; set; } = "DEFAULT";

    /// <summary>本服务在注册中心里的逻辑名，如 product</summary>
    public string ServiceName { get; set; } = string.Empty;

    public string Scheme { get; set; } = "http";

    /// <summary>
    /// 注册端口。为 0 时从 Kestrel 实际监听地址推导（推荐，避免配置与实际监听漂移）。
    /// </summary>
    public int Port { get; set; }

    /// <summary>
    /// 注册 IP。为空时按 <see cref="PreferredNetworks"/> 自动选一张网卡。
    /// 容器场景强烈建议显式指定或配好 PreferredNetworks，否则可能注册成 127.0.0.1。
    /// </summary>
    public string? Ip { get; set; }

    public double Weight { get; set; } = 1.0;

    /// <summary>
    /// 选网卡时的优先前缀。按数组顺序匹配，第一个命中的网卡 IP 被采用。
    /// </summary>
    public List<string> PreferredNetworks { get; set; } = new() { "192.168.", "10.", "172." };

    /// <summary>
    /// 是否走 gRPC 与 Nacos 通信。
    /// 默认 false：实测 nacos-sdk-csharp 1.3.10 的 gRPC 与 Nacos 2.5.4 握手失败
    /// （Client not connected, -401），HTTP 模式四步验证全通。
    /// </summary>
    public bool NamingUseRpc { get; set; }

    /// <summary>是否启用自动注册（调试时可关掉，只做发现）</summary>
    public bool RegisterEnabled { get; set; } = true;

    public int DefaultTimeOut { get; set; } = 15_000;
}
