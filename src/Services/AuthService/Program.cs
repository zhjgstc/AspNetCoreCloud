using AspNetCoreCloud.Observability;
using AspNetCoreCloud.ServiceDiscovery;
using AspNetCoreCloud.ServiceDiscovery.Nacos;

var builder = WebApplication.CreateBuilder(args);

// 可观测：trace / metrics / logs 一次接好，导出地址由环境变量决定
builder.AddAspNetCoreCloudObservability("auth");

builder.Services.AddControllers();
builder.Services.AddHealthChecks();

// 注册与发现：非 K8s 走 Nacos。业务代码只依赖 IServiceDiscovery 抽象，
// 换成别的注册中心时这里改一行，控制器不用动。
builder.Services.AddNacosServiceDiscovery(builder.Configuration);

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseDeveloperExceptionPage();
}

app.UseTraceIdResponseHeader();
app.MapServiceHealthChecks();
app.MapControllers();

app.Run();
