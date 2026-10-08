using AspNetCoreCloud.ServiceDiscovery;
using AspNetCoreCloud.ServiceDiscovery.Nacos;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.AddHealthChecks();

builder.Services.AddNacosServiceDiscovery(builder.Configuration);

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseDeveloperExceptionPage();
}

app.MapServiceHealthChecks();
app.MapControllers();

app.Run();
