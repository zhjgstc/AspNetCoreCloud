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

    /// <summary>
    /// Nacos 服务地址，如 http://nacos:8848。
    ///
    /// 默认值刻意留空：配置绑定器对集合属性是「追加」而不是「替换」，
    /// 若这里给默认地址，配置里的地址会被追加在后面，SDK 就会去连一个本机不存在的
    /// localhost:8848（实测出现过：同时连 localhost:8848 和真实地址，前者一直失败）。
    /// 缺省值在 AddNacosServiceDiscovery 里兜底。
    /// </summary>
    public List<string> ServerAddresses { get; set; } = [];

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
    /// 同样留空默认值，避免与配置重复；为空时退化为「第一个非回环 IPv4」。
    /// </summary>
    public List<string> PreferredNetworks { get; set; } = [];

    /// <summary>
    /// 是否走 gRPC 与 Nacos 通信。
    /// 默认 false：实测 nacos-sdk-csharp 1.3.10 的 gRPC 与 Nacos 2.5.4 握手失败
    /// （Client not connected, -401），HTTP 模式四步验证全通。
    /// </summary>
    public bool NamingUseRpc { get; set; }

    /// <summary>
    /// 发现实例时是否走 SDK 的订阅缓存。
    ///
    /// 默认 true：靠订阅 + 本地缓存，请求量小，Nacos 短暂不可用也能继续调用。
    /// 但缓存主要靠服务端的 UDP 推送更新 —— 跨公网/NAT 时推送到不了客户端
    /// （实测：注册中心上明明有 2 个实例，网关 30 秒内始终只看到 1 个）。
    ///
    /// 因此**网关必须设为 false**：它是路由决策方，宁可多几次查询也要拿到最新实例。
    /// </summary>
    public bool UseSubscribeCache { get; set; } = true;

    /// <summary>是否启用自动注册（调试时可关掉，只做发现）</summary>
    public bool RegisterEnabled { get; set; } = true;

    public int DefaultTimeOut { get; set; } = 15_000;
}
