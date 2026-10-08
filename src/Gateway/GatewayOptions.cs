namespace AspNetCoreCloud.Gateway;

/// <summary>
/// 网关自身的行为配置。
///
/// 设计原则：约定优于配置。默认按 <c>/api/{service}/**</c> 自动为 Nacos 里的每个服务
/// 生成路由，只有需要例外（匿名放行、单独限流）时才写进这里。
/// </summary>
public sealed record GatewayOptions
{
    public const string SectionName = "Gateway";

    /// <summary>未在配置中指定时使用的默认服务列表。</summary>
    public static readonly string[] DefaultServices = ["auth", "order", "product"];

    /// <summary>
    /// 需要代理的服务名列表（必须与各服务注册到 Nacos 的名字一致）。
    /// 每个服务会生成一条 <c>/api/{name}/{**catch-all}</c> 路由。
    ///
    /// 注意默认值刻意留空：配置绑定器对只读集合是「追加」而不是「替换」，
    /// 若这里给默认值，配置里的服务会被追加到默认值后面，导致重复路由。
    /// 缺省值在 Program.cs 里兜底赋值。
    /// </summary>
    public IReadOnlyList<string> Services { get; init; } = [];

    /// <summary>路由前缀，默认 /api。</summary>
    public string RoutePrefix { get; init; } = "/api";

    /// <summary>
    /// 从注册中心拉取实例并重建路由表的周期（秒）。
    /// 这是热更新的来源：实例上下线最多在这个间隔内反映到路由表。
    /// </summary>
    public int RefreshIntervalSeconds { get; init; } = 5;

    /// <summary>负载均衡策略：RoundRobin / LeastRequests / PowerOfTwoChoices / Random / FirstAlphabetical。</summary>
    public string LoadBalancingPolicy { get; init; } = "RoundRobin";

    /// <summary>是否启用 YARP 主动健康检查（定时探活，失败实例自动摘除）。</summary>
    public bool EnableActiveHealthCheck { get; init; } = true;

    /// <summary>主动健康检查路径，与各服务暴露的 /health/ready 对齐。</summary>
    public string HealthCheckPath { get; init; } = "/health/ready";

    /// <summary>主动健康检查间隔（秒）。</summary>
    public int HealthCheckIntervalSeconds { get; init; } = 5;

    /// <summary>
    /// 匿名放行的路径前缀（不需要 JWT）。网关自身的 /health、/gateway/** 默认放行。
    /// </summary>
    public IReadOnlyList<string> AnonymousPaths { get; init; } = [];

    /// <summary>限流：每个源 IP 在窗口期内允许的请求数。0 表示不限流。</summary>
    public int RateLimitPermitLimit { get; init; } = 200;

    /// <summary>限流窗口（秒）。</summary>
    public int RateLimitWindowSeconds { get; init; } = 1;

    /// <summary>是否启用演示用的 token 签发端点 /gateway/token。生产环境务必关闭。</summary>
    public bool EnableDemoTokenEndpoint { get; init; } = true;
}
