using System.Text.Json;
using Microsoft.AspNetCore.Mvc;

namespace ProductService.Controllers;

[ApiController]
[Route("api/product")]
public class ProductsController : ControllerBase
{
    [HttpGet("health")]
    public IActionResult Health() => Ok();

    [HttpGet("test")]
    public IActionResult Test() => Content("123");

    /// <summary>
    /// 返回「我是哪个实例」—— 用来验证请求被分发到了哪个实例。
    ///
    /// 格式：<c>hostname|ip:port</c>，例如 <c>3f9a1c2e|172.19.0.4:10300</c>。
    /// 为什么带 hostname：容器里 hostname 就是容器短 ID，多实例时各不相同；
    /// 而端口在 scale 出来的一批实例里是一样的（都是 10300），只看端口分不出实例。
    ///
    /// 刻意只用 ASP.NET 原生 API（Connection.LocalIpAddress / LocalPort），
    /// 不依赖任何注册中心 —— 业务代码始终不知道自己跑在 Nacos 还是 K8s 上。
    /// </summary>
    [HttpGet("instance")]
    public IActionResult Instance()
    {
        var host = Environment.MachineName;
        var ip = HttpContext.Connection.LocalIpAddress?.ToString() ?? "unknown";
        var port = HttpContext.Connection.LocalPort;

        return Content($"{host}|{ip}:{port}");
    }

    [HttpPost("add")]
    public IActionResult Add([FromBody] JsonElement data)
    {
        var a = data.GetProperty("a").ToString();
        var b = data.GetProperty("b").ToString();
        return Content($"a:{a},b:{b}");
    }

    [HttpPost("new")]
    public IActionResult New([FromBody] User user)
        => Content($"Name:{user.Name},Age:{user.Age}");
}

public class User
{
    public string Name { get; set; } = string.Empty;
    public string? Age { get; set; }
}
