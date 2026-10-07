using System.Net.Http.Json;
using Microsoft.AspNetCore.Mvc;

namespace OrderService.Controllers;

[ApiController]
[Route("api/order")]
public class OrdersController : ControllerBase
{
    private readonly IHttpClientFactory _httpClientFactory;
    private readonly ILogger<OrdersController> _logger;

    public OrdersController(IHttpClientFactory httpClientFactory, ILogger<OrdersController> logger)
    {
        _httpClientFactory = httpClientFactory;
        _logger = logger;
    }

    [HttpGet("health")]
    public IActionResult Health() => Ok();

    /// <summary>
    /// 跨服务调用演示：order -> auth / product。
    /// 原 HomeController.Test 通过 Consul 查实例后硬编码端口调用，
    /// 现在走 IHttpClientFactory + 配置基址；M2 换成服务发现后本方法不变。
    /// </summary>
    [HttpGet("test")]
    public async Task<IActionResult> Test(CancellationToken ct)
    {
        var auth = await CallGetAsync("auth", "api/auth/echo-token", ct);
        var product = await CallGetAsync("product", "api/product/test", ct);

        return Content($"order -> auth: {auth}{Environment.NewLine}order -> product: {product}");
    }

    /// <summary>跨服务 POST 演示：order -> product/api/product/new</summary>
    [HttpPost("create")]
    public async Task<IActionResult> Create([FromBody] CreateOrderRequest request, CancellationToken ct)
    {
        var product = await CallPostAsync("product", "api/product/new", request, ct);
        return Content($"order -> product(new): {product}");
    }

    private async Task<string> CallGetAsync(string clientName, string path, CancellationToken ct)
    {
        try
        {
            var client = _httpClientFactory.CreateClient(clientName);
            using var response = await client.GetAsync(path, ct);
            var body = await response.Content.ReadAsStringAsync(ct);
            return $"[{(int)response.StatusCode}] {body}";
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "调用服务 {Service} 的 {Path} 失败", clientName, path);
            return $"[error] {ex.Message}";
        }
    }

    private async Task<string> CallPostAsync(string clientName, string path, object payload, CancellationToken ct)
    {
        try
        {
            var client = _httpClientFactory.CreateClient(clientName);
            using var response = await client.PostAsJsonAsync(path, payload, ct);
            var body = await response.Content.ReadAsStringAsync(ct);
            return $"[{(int)response.StatusCode}] {body}";
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "调用服务 {Service} 的 {Path} 失败", clientName, path);
            return $"[error] {ex.Message}";
        }
    }
}

public class CreateOrderRequest
{
    public string Name { get; set; } = string.Empty;
    public string? Age { get; set; }
}
