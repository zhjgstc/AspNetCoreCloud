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
    /// 返回本实例实际监听的端口 —— 用于验证请求被分发到了哪个实例。
    /// 刻意只用 ASP.NET 原生 API（Connection.LocalPort），不依赖任何注册中心，
    /// 这样业务代码永远不知道自己跑在 Nacos 还是 K8s 上。
    /// </summary>
    [HttpGet("instance")]
    public IActionResult Instance() => Content($"{HttpContext.Connection.LocalPort}");

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
