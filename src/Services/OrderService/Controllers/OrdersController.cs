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

    /// <summary>
    /// 客户端负载均衡演示：连续调用 product 若干次，统计请求落在哪些实例上。
    /// 因为 product 起了多个实例，命中分布应该分散 —— 这是「非 K8s 没有 kube-proxy，
    /// 负载均衡由调用方自己做」的直接证据。
    /// </summary>
    [HttpGet("lb")]
    public async Task<IActionResult> LoadBalance(CancellationToken ct)
    {
        var hits = new Dictionary<string, int>();

        for (var i = 0; i < 6; i++)
        {
            var body = await CallGetAsync("product", "api/product/instance", ct);
            hits[body] = hits.GetValueOrDefault(body) + 1;
        }

        var lines = hits
            .OrderBy(kv => kv.Key, StringComparer.Ordinal)
            .Select(kv => $"  实例 {kv.Key} 命中 {kv.Value} 次");

        return Content($"product 共 {hits.Count} 个实例：{Environment.NewLine}{string.Join(Environment.NewLine, lines)}");
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
