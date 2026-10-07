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
