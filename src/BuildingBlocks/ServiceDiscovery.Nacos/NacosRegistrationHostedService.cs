using Microsoft.AspNetCore.Hosting.Server;
using Microsoft.AspNetCore.Hosting.Server.Features;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Nacos.V2;

namespace AspNetCoreCloud.ServiceDiscovery.Nacos;

/// <summary>
/// 把「注册 / 摘除」挂在主机生命周期上：
///   ApplicationStarted  → 注册
///   ApplicationStopping → 摘除 + 关闭 Nacos 连接
///
/// 放在 Nacos 工程而不是抽象层，是因为这件事本身就是注册中心特有的 ——
/// K8s 下由 Service DNS 负责，根本不需要注册动作。
/// </summary>
public sealed class NacosRegistrationHostedService : IHostedService
{
    private readonly IServiceRegistry _registry;
    private readonly INacosNamingService _naming;
    private readonly NacosDiscoveryOptions _options;
    private readonly IServer? _server;
    private readonly ILogger<NacosRegistrationHostedService> _logger;

    private ServiceRegistration? _registration;

    public NacosRegistrationHostedService(
        IServiceRegistry registry,
        INacosNamingService naming,
        NacosDiscoveryOptions options,
        ILogger<NacosRegistrationHostedService> logger,
        IServer? server = null)
    {
        _registry = registry;
        _naming = naming;
        _options = options;
        _logger = logger;
        _server = server;
    }

    public async Task StartAsync(CancellationToken ct)
    {
        if (!_options.RegisterEnabled)
        {
            _logger.LogInformation("Nacos 自动注册已关闭（Nacos:RegisterEnabled=false）");
            return;
        }

        if (string.IsNullOrWhiteSpace(_options.ServiceName))
        {
            _logger.LogError("未配置 Nacos:ServiceName，跳过注册");
            return;
        }

        if (string.IsNullOrEmpty(_options.Password))
        {
            _logger.LogWarning("Nacos:Password 为空。若 Nacos 开启了鉴权，注册会以 403 失败；" +
                               "请用环境变量 Nacos__Password 注入。");
        }

        var ip = LocalIpResolver.Resolve(_options.PreferredNetworks, _options.Ip);
        var port = _options.Port > 0 ? _options.Port : ResolveListeningPort();

        _registration = new ServiceRegistration(
            _options.ServiceName,
            $"{ip}-{port}-{Environment.ProcessId}",
            ip,
            port,
            _options.Scheme);

        try
        {
            await _registry.RegisterAsync(_registration, ct);
        }
        catch (Exception ex)
        {
            // 注册中心不可达不应该让服务起不来 —— 服务本身仍能被直连调用
            _logger.LogError(ex, "注册到 Nacos 失败，服务继续启动，但不会被网关发现");
        }
    }

    public async Task StopAsync(CancellationToken ct)
    {
        if (_registration is not null)
        {
            try
            {
                await _registry.DeregisterAsync(_registration, ct);
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "从 Nacos 摘除失败（临时实例也会在心跳超时后自动消失）");
            }
        }

        try
        {
            await _naming.ShutDown();
        }
        catch (Exception ex)
        {
            _logger.LogDebug(ex, "关闭 Nacos 连接时出错，忽略");
        }
    }

    /// <summary>兜底：从 Kestrel 实际绑定的地址推导端口（通常已在配置阶段由 URLs 推导出）。</summary>
    private int ResolveListeningPort()
    {
        var addresses = _server?.Features.Get<IServerAddressesFeature>()?.Addresses?.ToList();

        _logger.LogDebug(
            "Nacos 地址={NacosAddresses}；Kestrel 监听地址={ListenAddresses}",
            string.Join(",", _options.ServerAddresses),
            addresses is null ? "<IServer 不可用>" : string.Join(",", addresses));

        var port = ListeningPortResolver.FromAddresses(addresses);

        if (port <= 0)
        {
            _logger.LogWarning("无法推导监听端口，回退到 80。建议在 Nacos:Port 显式配置。");
            return 80;
        }

        return port;
    }
}
