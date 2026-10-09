using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using AspNetCoreCloud.Gateway;
using AspNetCoreCloud.Observability;
using AspNetCoreCloud.ServiceDiscovery;
using AspNetCoreCloud.ServiceDiscovery.Nacos;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.RateLimiting;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;
using System.Threading.RateLimiting;
using Yarp.ReverseProxy.Configuration;

var builder = WebApplication.CreateBuilder(args);

// 可观测：网关的入站 span 与转发到下游的出站 span 会自动串成一条完整链路
builder.AddAspNetCoreCloudObservability("gateway");

var jwtSection = builder.Configuration.GetSection("Jwt");
var signingKey = jwtSection["Key"];

if (string.IsNullOrWhiteSpace(signingKey))
{
    throw new InvalidOperationException("缺少配置 Jwt:Key，网关无法校验令牌。");
}

// ── 网关行为配置 ───────────────────────────────────────────────
var gatewayOptions = builder.Configuration.GetSection(GatewayOptions.SectionName).Get<GatewayOptions>()
                     ?? new GatewayOptions();

// 服务列表兜底 + 去重：重复的服务名会生成两条匹配同一路径的路由
var services = (gatewayOptions.Services.Count == 0
        ? GatewayOptions.DefaultServices
        : gatewayOptions.Services)
    .Distinct(StringComparer.OrdinalIgnoreCase)
    .ToList();

gatewayOptions = gatewayOptions with { Services = services };
builder.Services.AddSingleton(Options.Create(gatewayOptions));

// ── 服务发现（复用同一套抽象，网关自己也注册进 Nacos 便于观测）──
builder.Services.AddNacosServiceDiscovery(builder.Configuration);
builder.Services.AddHealthChecks();

// ── YARP ──────────────────────────────────────────────────────
// 注意注册顺序：先 AddReverseProxy()，再注册自定义 Provider，
// DI 解析 IProxyConfigProvider 时取最后注册的那个，从而覆盖内置实现。
builder.Services.AddReverseProxy();
builder.Services.AddSingleton<NacosProxyConfigProvider>();
builder.Services.AddSingleton<IProxyConfigProvider>(sp => sp.GetRequiredService<NacosProxyConfigProvider>());
builder.Services.AddHostedService<ProxyConfigRefreshService>();

// ── JWT 鉴权 ──────────────────────────────────────────────────
builder.Services
    .AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateIssuerSigningKey = true,
            ValidateLifetime = true,
            ValidIssuer = jwtSection["Issuer"],
            ValidAudience = jwtSection["Audience"],
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(signingKey)),
            ClockSkew = TimeSpan.FromSeconds(30)
        };

        // 兼容旧 demo 的自定义头：curl -H "token: xxx" 也能通过校验。
        // 正式系统应只用标准 Authorization: Bearer。
        options.Events = new JwtBearerEvents
        {
            OnMessageReceived = context =>
            {
                if (context.Request.Headers.TryGetValue("token", out var raw))
                {
                    context.Token = raw.ToString();
                }

                return Task.CompletedTask;
            }
        };
    });

builder.Services.AddAuthorization(options =>
{
    options.AddPolicy(
        NacosProxyConfigProvider.AuthorizationPolicyName,
        policy => policy.RequireAuthenticatedUser());
});

// ── 限流（按源 IP 固定窗口）─────────────────────────────────────
// 替换 Ocelot 的 RateLimitOptions：用 .NET 内置限流器，不引第三方包
builder.Services.AddRateLimiter(options =>
{
    options.RejectionStatusCode = StatusCodes.Status429TooManyRequests;

    options.AddPolicy(
        NacosProxyConfigProvider.RateLimiterPolicyName,
        httpContext => RateLimitPartition.GetFixedWindowLimiter(
            partitionKey: httpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown",
            factory: _ => new FixedWindowRateLimiterOptions
            {
                PermitLimit = gatewayOptions.RateLimitPermitLimit,
                Window = TimeSpan.FromSeconds(Math.Max(1, gatewayOptions.RateLimitWindowSeconds)),
                QueueProcessingOrder = QueueProcessingOrder.OldestFirst,
                QueueLimit = 0
            }));
});

var app = builder.Build();

app.UseTraceIdResponseHeader();
app.UseRouting();
app.UseAuthentication();
app.UseAuthorization();
app.UseRateLimiter();

// 网关自身健康检查（/health、/health/live、/health/ready）
app.MapServiceHealthChecks();

// 诊断端点：/gateway/routes、/gateway/token
app.MapGatewayDiagnostics(gatewayOptions, jwtSection);

// 反向代理：路由表由 NacosProxyConfigProvider 动态提供
app.MapReverseProxy();

app.Run();
