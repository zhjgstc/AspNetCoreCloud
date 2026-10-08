namespace AspNetCoreCloud.ServiceDiscovery.Nacos;

/// <summary>
/// 推导本实例对外监听端口。
///
/// 为什么需要它：注册中心里的端口必须和真实监听端口一致，否则网关会转发到一个没人听的地址。
/// 与其让开发者在两处维护同一个数字，不如从唯一真相来源推导。
/// </summary>
internal static class ListeningPortResolver
{
    /// <summary>从 Kestrel 的 URLs 配置推导（appsettings 的 "Urls" 或 ASPNETCORE_URLS）。</summary>
    public static int FromUrls(string? urls)
    {
        if (string.IsNullOrWhiteSpace(urls))
        {
            return 0;
        }

        foreach (var part in urls.Split(';', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries))
        {
            var port = ParsePort(part);
            if (port > 0)
            {
                return port;
            }
        }

        return 0;
    }

    /// <summary>从 Kestrel 实际绑定的地址推导（兜底，覆盖没有显式配置 URLs 的场景）。</summary>
    public static int FromAddresses(IEnumerable<string>? addresses)
    {
        if (addresses is null)
        {
            return 0;
        }

        foreach (var address in addresses)
        {
            var port = ParsePort(address);
            if (port > 0)
            {
                return port;
            }
        }

        return 0;
    }

    private static int ParsePort(string address)
    {
        // Kestrel 支持 * / + / [::] 这类通配写法，Uri 解析不了，先换成 localhost
        var normalized = address
            .Replace("*", "localhost")
            .Replace("+", "localhost")
            .Replace("[::]", "localhost");

        return Uri.TryCreate(normalized, UriKind.Absolute, out var uri) ? uri.Port : 0;
    }
}
