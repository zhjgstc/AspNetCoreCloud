var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.AddHealthChecks();

// 服务间调用：基址来自配置 Services:{Name}。
// M2 引入 IServiceDiscovery 后，这里会改成从注册中心解析出的健康实例地址，
// 控制器代码不需要改动 —— 控制器只认 "auth" / "product" 这两个逻辑名。
builder.Services.AddHttpClient("auth", c =>
    c.BaseAddress = new Uri(builder.Configuration["Services:Auth"] ?? "http://localhost:10100"));

builder.Services.AddHttpClient("product", c =>
    c.BaseAddress = new Uri(builder.Configuration["Services:Product"] ?? "http://localhost:10300"));

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseDeveloperExceptionPage();
}

app.MapHealthChecks("/health");
app.MapControllers();

app.Run();
