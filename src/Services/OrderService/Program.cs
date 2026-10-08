using AspNetCoreCloud.ServiceDiscovery;
using AspNetCoreCloud.ServiceDiscovery.Nacos;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.AddHealthChecks();

builder.Services.AddNacosServiceDiscovery(builder.Configuration);

// 跨服务调用：只写逻辑服务名，真实地址在请求发出前由
// ServiceDiscoveryHttpMessageHandler 从注册中心解析 —— 实例上下线无需重启本服务。
builder.Services.AddServiceDiscoveryHttpClient("auth");
builder.Services.AddServiceDiscoveryHttpClient("product");

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseDeveloperExceptionPage();
}

app.MapServiceHealthChecks();
app.MapControllers();

app.Run();
