using Microsoft.AspNetCore.Mvc;

namespace AuthService.Controllers;

[ApiController]
[Route("api/auth")]
public class AuthController : ControllerBase
{
    private readonly ILogger<AuthController> _logger;

    public AuthController(ILogger<AuthController> logger) => _logger = logger;

    [HttpGet("health")]
    public IActionResult Health() => Ok();

    /// <summary>
    /// 回显请求头中的 token —— 用于验证网关是否把身份信息透传到了下游服务。
    /// 原 HomeController.Index 的行为，路由从 /home/index 改为 /api/auth/echo-token。
    /// </summary>
    [HttpGet("echo-token")]
    public IActionResult EchoToken()
    {
        var token = Request.Headers["token"].ToString();
        _logger.LogInformation("收到 token，长度 {Length}", token.Length);
        return Content(string.IsNullOrWhiteSpace(token) ? "<empty>" : token);
    }
}
