using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Diagnostics.HealthChecks;
using Microsoft.AspNetCore.Routing;

namespace AspNetCoreCloud.ServiceDiscovery;

/// <summary>
/// 统一的健康检查端点约定。注册中心、K8s 探针、YARP 主动健康检查都依赖这套约定，
/// 所以放在 BuildingBlocks 里保证所有服务一致。
/// </summary>
public static class ServiceHealthEndpointExtensions
{
    /// <summary>
    /// 映射三个端点：
    /// <list type="bullet">
    ///   <item><c>/health</c> — 全部检查项（兼容旧路径，给人看）</item>
    ///   <item><c>/health/live</c> — 存活探针：进程能响应即算活，不跑任何检查项</item>
    ///   <item><c>/health/ready</c> — 就绪探针：跑全部检查项，不就绪则从负载里摘除</item>
    /// </list>
    /// </summary>
    public static void MapServiceHealthChecks(this IEndpointRouteBuilder endpoints)
    {
        endpoints.MapHealthChecks("/health");
        endpoints.MapHealthChecks("/health/live", new HealthCheckOptions { Predicate = _ => false });
        endpoints.MapHealthChecks("/health/ready");
    }
}
