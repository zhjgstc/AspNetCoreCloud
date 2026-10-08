using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using Yarp.ReverseProxy.Configuration;

namespace AspNetCoreCloud.Gateway;

/// <summary>
/// 网关自带的可观测与演示端点。
///
/// 这些端点存在的唯一目的是让「动态路由」这件事看得见：
/// 服务扩缩容后不用重启网关，直接 GET /gateway/routes 就能看到实例列表变了。
/// </summary>
public static class GatewayDiagnosticsExtensions
{
    public static IEndpointRouteBuilder MapGatewayDiagnostics(
        this IEndpointRouteBuilder endpoints,
        GatewayOptions options,
        IConfiguration jwtSection)
    {
        // 当前路由表快照：服务名 -> 实例地址列表
        endpoints.MapGet("/gateway/routes", (NacosProxyConfigProvider provider) =>
        {
            var snapshot = provider.Snapshot;
            var config = provider.GetConfig();

            return Results.Ok(new
            {
                revision = config.RevisionId,
                routes = config.Routes.Select(r => new
                {
                    id = r.RouteId,
                    path = r.Match.Path,
                    cluster = r.ClusterId,
                    auth = r.AuthorizationPolicy ?? "(匿名)",
                    rateLimiter = r.RateLimiterPolicy ?? "(不限)"
                }),
                instances = snapshot.Select(s => new
                {
                    service = s.Key,
                    count = s.Value.Count,
                    addresses = s.Value
                })
            });
        });

        // 演示用签发端点：便于 curl 拿到 token 验证 401/200 的差异。
        // 正式系统登录签发应由 AuthService 负责，这里默认只在开发/演示开启。
        endpoints.MapGet("/gateway/token", () =>
        {
            if (!options.EnableDemoTokenEndpoint)
            {
                return Results.NotFound();
            }

            var key = jwtSection["Key"] ?? string.Empty;
            var handler = new JwtSecurityTokenHandler();

            var descriptor = new SecurityTokenDescriptor
            {
                Subject = new ClaimsIdentity(
                [
                    new Claim(ClaimTypes.Name, "demo-user"),
                    new Claim(ClaimTypes.NameIdentifier, "demo-user-id"),
                    new Claim("scope", "api")
                ]),
                Expires = DateTime.UtcNow.AddHours(2),
                Issuer = jwtSection["Issuer"],
                Audience = jwtSection["Audience"],
                SigningCredentials = new SigningCredentials(
                    new SymmetricSecurityKey(Encoding.UTF8.GetBytes(key)),
                    SecurityAlgorithms.HmacSha256)
            };

            var token = handler.WriteToken(handler.CreateToken(descriptor));

            return Results.Ok(new
            {
                accessToken = token,
                tokenType = "Bearer",
                expiresIn = 7200,
                usage = "curl -H 'Authorization: Bearer <accessToken>' http://localhost:10000/api/product/test"
            });
        });

        endpoints.MapGet("/gateway", () => Results.Ok(new
        {
            service = "AspNetCoreCloud.Gateway",
            endpoints = new[] { "/gateway/routes", "/gateway/token", "/health", "/health/live", "/health/ready" },
            upstream = options.Services.Select(s => $"{options.RoutePrefix.TrimEnd('/')}/{s}/**")
        }));

        return endpoints;
    }
}
