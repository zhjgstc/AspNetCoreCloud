using AspNetCoreCloud.Observability;
using AspNetCoreCloud.ServiceDiscovery;
using AspNetCoreCloud.ServiceDiscovery.Nacos;

var builder = WebApplication.CreateBuilder(args);

// 可观测：trace / metrics / logs 一次接好，导出地址由环境变量决定
builder.AddAspNetCoreCloudObservability("product");

builder.Services.AddControllers();
builder.Services.AddHealthChecks();

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
