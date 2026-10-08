using Microsoft.Extensions.Options;

namespace AspNetCoreCloud.Gateway;

/// <summary>
/// 定时从注册中心拉实例并重建路由表。
///
/// 这是非 K8s 路径下"实例上下线自动生效"的驱动源：
/// 服务扩缩容、进程退出、机器故障，最多在一个刷新周期内反映到网关路由表。
/// </summary>
public sealed class ProxyConfigRefreshService : BackgroundService
{
    private readonly NacosProxyConfigProvider _provider;
    private readonly GatewayOptions _options;
    private readonly ILogger<ProxyConfigRefreshService> _logger;

    public ProxyConfigRefreshService(
        NacosProxyConfigProvider provider,
        IOptions<GatewayOptions> options,
        ILogger<ProxyConfigRefreshService> logger)
    {
        _provider = provider;
        _options = options.Value;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        var interval = TimeSpan.FromSeconds(Math.Max(1, _options.RefreshIntervalSeconds));

        // 启动时先同步一次，避免网关起来后有一段"空路由"窗口
        await _provider.RefreshAsync(stoppingToken);

        using var timer = new PeriodicTimer(interval);

        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                await timer.WaitForNextTickAsync(stoppingToken);
            }
            catch (OperationCanceledException)
            {
                break;
            }

            await _provider.RefreshAsync(stoppingToken);
        }

        _logger.LogInformation("路由刷新服务已停止");
    }
}
