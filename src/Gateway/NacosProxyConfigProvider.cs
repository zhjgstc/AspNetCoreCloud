using System.Collections.Concurrent;
using System.Security.Cryptography;
using System.Text;
using AspNetCoreCloud.ServiceDiscovery;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Options;
using Microsoft.Extensions.Primitives;
using Yarp.ReverseProxy.Configuration;
using Yarp.ReverseProxy.Health;

namespace AspNetCoreCloud.Gateway;

/// <summary>
/// 把注册中心里的实例列表，翻译成 YARP 的路由表 —— 这是非 K8s 路径的核心。
///
/// 为什么必须自己写这个 Provider：
/// K8s 里每个服务有稳定的 Service DNS，cluster 配 1 个 destination 交给 kube-proxy 负载即可；
/// 非 K8s 没有这层，实例地址会随时变化，必须把注册中心返回的全部实例列为 destination，
/// 并在实例上下线时重建路由表。
///
/// 热更新如何做到不中断：
/// 内部持有 InMemoryConfigProvider，每次刷新调用它的 Update() 原子替换整份配置 ——
/// 已在途的请求继续用旧配置处理完，新请求用新配置，网关全程不重启。
/// </summary>
public sealed class NacosProxyConfigProvider : IProxyConfigProvider
{
    /// <summary>限流策略名，与 Program.cs 里 AddRateLimiter 注册的名字对应。</summary>
    public const string RateLimiterPolicyName = "gateway-per-ip";

    /// <summary>需要登录的路由引用的授权策略名。</summary>
    public const string AuthorizationPolicyName = "gateway-authenticated";

    private readonly IServiceDiscovery _discovery;
    private readonly GatewayOptions _options;
    private readonly ILogger<NacosProxyConfigProvider> _logger;
    private readonly InMemoryConfigProvider _inner;
    private readonly IReadOnlyList<RouteConfig> _fallbackRoutes;
    private readonly IReadOnlyList<ClusterConfig> _fallbackClusters;

    private readonly SemaphoreSlim _gate = new(1, 1);
    private string _revision = string.Empty;

    public NacosProxyConfigProvider(
        IServiceDiscovery discovery,
        IOptions<GatewayOptions> options,
        IConfiguration configuration,
        ILogger<NacosProxyConfigProvider> logger)
    {
        _discovery = discovery;
        _options = options.Value;
        _logger = logger;

        // 兜底静态路由：注册中心不可用时，至少还能按 appsettings 的 ReverseProxy 段转发
        _fallbackRoutes = configuration.GetSection("ReverseProxy:Routes").Get<RouteConfig[]>() ?? [];
        _fallbackClusters = ReadFallbackClusters(configuration);

        _inner = new InMemoryConfigProvider(_fallbackRoutes, _fallbackClusters, "fallback");

        logger.LogInformation(
            "网关已初始化：动态服务 {Services} 个，静态兜底路由 {FallbackRoutes} 条",
            _options.Services.Count, _fallbackRoutes.Count);
    }

    public IProxyConfig GetConfig() => _inner.GetConfig();

    /// <summary>当前每个服务的实例数，供 /gateway/routes 观测热更新效果。</summary>
    public IReadOnlyDictionary<string, IReadOnlyList<string>> Snapshot { get; private set; }
        = new Dictionary<string, IReadOnlyList<string>>();

    /// <summary>
    /// 拉一次注册中心，重建路由表。由 <see cref="ProxyConfigRefreshService"/> 定时调用。
    /// 实例集合没变化时不调用 Update，避免无谓地重建路由。
    /// </summary>
    public async Task RefreshAsync(CancellationToken ct = default)
    {
        await _gate.WaitAsync(ct);
        try
        {
            var routes = new List<RouteConfig>();
            var clusters = new List<ClusterConfig>();
            var snapshot = new Dictionary<string, IReadOnlyList<string>>();
            var addresses = new List<string>();

            foreach (var serviceName in _options.Services)
            {
                var instances = await _discovery.ResolveAsync(serviceName, ct);

                // 每个服务都生成路由，即使暂时无实例 —— 无实例时 YARP 返回 503，
                // 语义比 404 更准确（"我知道这个服务，但它现在没实例"）。
                routes.Add(BuildRoute(serviceName));

                if (instances.Count == 0)
                {
                    snapshot[serviceName] = [];
                    continue;
                }

                clusters.Add(BuildCluster(serviceName, instances));
                snapshot[serviceName] = instances.Select(i => i.Address).ToList();
                addresses.AddRange(instances.Select(i => $"{serviceName}={i.InstanceId}@{i.Address}"));
            }

            // 静态兜底：只补充"动态里没有实例"的服务对应的 cluster。
            // 注意这里刻意不补充静态 Route —— 它的 path 与动态路由完全相同，
            // 加进去会产生两条匹配同一路径的路由，反而让转发结果不确定。
            // 路由始终由上面统一生成，静态配置只提供 destination 兜底。
            foreach (var cluster in _fallbackClusters)
            {
                if (clusters.Any(c => string.Equals(c.ClusterId, cluster.ClusterId, StringComparison.OrdinalIgnoreCase)))
                {
                    continue;
                }

                clusters.Add(cluster);
                _logger.LogWarning(
                    "服务 {Service} 在注册中心无实例，已启用静态兜底地址",
                    cluster.ClusterId);
            }

            var revision = ComputeRevision(addresses);
            if (string.Equals(revision, _revision, StringComparison.Ordinal))
            {
                Snapshot = snapshot;
                return;
            }

            var previous = _revision;
            _revision = revision;
            Snapshot = snapshot;

            _inner.Update(routes, clusters, revision);

            if (previous.Length > 0)
            {
                _logger.LogInformation("路由表已热更新：{Routes} 条路由 / {Clusters} 个集群", routes.Count, clusters.Count);
            }
        }
        catch (Exception ex) when (ex is not OperationCanceledException)
        {
            // 刷新失败不能让网关崩：保留上一次的路由表继续服务
            _logger.LogError(ex, "刷新路由表失败，继续沿用当前配置");
        }
        finally
        {
            _gate.Release();
        }
    }

    private RouteConfig BuildRoute(string serviceName)
    {
        var path = $"{_options.RoutePrefix.TrimEnd('/')}/{serviceName}/{{**catch-all}}";

        return new RouteConfig
        {
            RouteId = $"{serviceName}-route",
            ClusterId = serviceName,
            Match = new RouteMatch { Path = path },
            AuthorizationPolicy = IsAnonymous(serviceName) ? null : AuthorizationPolicyName,
            RateLimiterPolicy = _options.RateLimitPermitLimit > 0 ? RateLimiterPolicyName : null
        };
    }

    private ClusterConfig BuildCluster(string serviceName, IReadOnlyList<ServiceEndpoint> instances)
    {
        var destinations = new Dictionary<string, DestinationConfig>(StringComparer.Ordinal);
        var ordinal = 0;

        foreach (var instance in instances)
        {
            // 注册中心返回的 InstanceId 理论上唯一，这里做去重兜底，避免 ToDictionary 抛异常
            var key = instance.InstanceId;
            while (!destinations.TryAdd(key, new DestinationConfig { Address = instance.Address }))
            {
                key = $"{instance.InstanceId}#{++ordinal}";
            }
        }

        return new ClusterConfig
        {
            ClusterId = serviceName,
            LoadBalancingPolicy = _options.LoadBalancingPolicy,
            Destinations = destinations,
            HealthCheck = new HealthCheckConfig
            {
                Active = new ActiveHealthCheckConfig
                {
                    Enabled = _options.EnableActiveHealthCheck,
                    Path = _options.HealthCheckPath,
                    Interval = TimeSpan.FromSeconds(_options.HealthCheckIntervalSeconds),
                    Timeout = TimeSpan.FromSeconds(3),
                    Policy = HealthCheckConstants.ActivePolicy.ConsecutiveFailures
                }
            }
        };
    }

    private bool IsAnonymous(string serviceName)
    {
        var path = $"{_options.RoutePrefix.TrimEnd('/')}/{serviceName}";
        return _options.AnonymousPaths.Any(p => path.StartsWith(p, StringComparison.OrdinalIgnoreCase));
    }

    private static List<ClusterConfig> ReadFallbackClusters(IConfiguration configuration)
    {
        var section = configuration.GetSection("ReverseProxy:Clusters");
        if (!section.Exists())
        {
            return [];
        }

        // YARP 的标准配置格式里 Clusters 是「clusterId -> 配置」的字典，
        // 绑定后需要把 key 回填进 ClusterId
        var raw = section.Get<Dictionary<string, ClusterConfig>>() ?? new Dictionary<string, ClusterConfig>();
        var result = new List<ClusterConfig>();

        foreach (var (clusterId, config) in raw)
        {
            // ClusterConfig 是 record 且 ClusterId 为 init-only，只能用 with 表达式改写
            result.Add(string.IsNullOrEmpty(config.ClusterId)
                ? config with { ClusterId = clusterId }
                : config);
        }

        return result;
    }

    private static string ComputeRevision(IEnumerable<string> addresses)
    {
        var joined = string.Join(";", addresses.OrderBy(a => a, StringComparer.Ordinal));
        var hash = SHA256.HashData(Encoding.UTF8.GetBytes(joined));
        return Convert.ToHexString(hash)[..16];
    }
}
