namespace AspNetCoreCloud.Observability;

/// <summary>
/// 可观测配置，对应配置节 <c>Observability</c>。
///
/// 设计原则：**代码只负责埋点，往哪导由环境决定。**
/// 后端地址优先取 <c>Observability:OtlpEndpoint</c>，其次取环境变量 <c>OTEL_EXPORTER_OTLP_ENDPOINT</c>，
/// 两者都没有时只生成数据、不导出（避免在没有收集端的环境下刷一堆连接失败日志）。
/// </summary>
public sealed class ObservabilityOptions
{
    public const string SectionName = "Observability";

    /// <summary>总开关，关闭后不注册任何 OTel 组件。</summary>
    public bool Enabled { get; set; } = true;

    /// <summary>
    /// 服务名。优先级：<c>OTEL_SERVICE_NAME</c> 环境变量 &gt; 本配置 &gt; 调用时传入的默认名。
    /// 建议与注册中心里的服务名保持一致，这样链路上的节点名和 Nacos 里能对上。
    /// </summary>
    public string? ServiceName { get; set; }

    /// <summary>服务版本，缺省取程序集 InformationalVersion。</summary>
    public string? ServiceVersion { get; set; }

    /// <summary>OTLP 端点，形如 <c>http://aspire-dashboard:18889</c>。留空则走环境变量。</summary>
    public string? OtlpEndpoint { get; set; }

    /// <summary>导出协议：<c>grpc</c>（默认）或 <c>http</c>/<c>http/protobuf</c>。</summary>
    public string? OtlpProtocol { get; set; }

    public bool EnableTraces { get; set; } = true;

    public bool EnableMetrics { get; set; } = true;

    /// <summary>日志走 OTLP 导出。控制台日志不受影响，两者并存。</summary>
    public bool EnableLogs { get; set; } = true;

    /// <summary>运行时指标（GC / 线程池 / 异常计数）。</summary>
    public bool EnableRuntimeMetrics { get; set; } = true;

    /// <summary>
    /// 不生成 span 的入站路径前缀。
    /// 注意：集合类型配置在 .NET 绑定器里是「追加」不是「替换」，所以这里默认留空，
    /// 缺省值由 <see cref="DefaultExcludedRequestPaths"/> 在代码里兜底。
    /// </summary>
    public List<string> ExcludedRequestPaths { get; set; } = new();

    /// <summary>不生成 span 的出站请求路径包含串（如注册中心心跳 <c>/nacos/</c>）。同上，默认留空。</summary>
    public List<string> ExcludedHttpPaths { get; set; } = new();

    /// <summary>入站默认排除：健康检查与诊断端点——它们由网关和容器频繁调用，进链路只会制造噪声。</summary>
    public static readonly string[] DefaultExcludedRequestPaths =
    [
        "/health",
        "/health/live",
        "/health/ready",
        "/health/startup",
        "/favicon.ico"
    ];

    /// <summary>出站默认排除：Nacos 的服务查询与心跳（每 5~10 秒一次，量极大且与业务无关）。</summary>
    public static readonly string[] DefaultExcludedHttpPaths =
    [
        "/nacos/"
    ];
}
