using System.Net;
using System.Net.NetworkInformation;
using System.Net.Sockets;

namespace AspNetCoreCloud.ServiceDiscovery.Nacos;

/// <summary>
/// 选出「对外可访问」的本机 IP。
///
/// 这是非 K8s + 容器场景下最容易出错的一环：默认的第一个网卡往往是回环或 docker0，
/// 注册上去之后网关拿到 127.0.0.1 会全部打不通。
///
/// 注意：nacos-sdk-csharp 1.3.10 没有 Java 客户端那种 PreferredNetworks 配置项，
/// 所以选 IP 这件事必须由我们自己完成。
/// </summary>
public static class LocalIpResolver
{
    public static string Resolve(IReadOnlyList<string> preferredNetworks, string? explicitIp = null)
    {
        if (!string.IsNullOrWhiteSpace(explicitIp))
        {
            return explicitIp;
        }

        var candidates = NetworkInterface.GetAllNetworkInterfaces()
            .Where(n => n.OperationalStatus == OperationalStatus.Up)
            .Where(n => n.NetworkInterfaceType != NetworkInterfaceType.Loopback)
            .SelectMany(n => n.GetIPProperties().UnicastAddresses)
            .Select(a => a.Address)
            .Where(a => a.AddressFamily == AddressFamily.InterNetwork)
            .Where(a => !IPAddress.IsLoopback(a))
            .Select(a => a.ToString())
            .Distinct()
            .ToList();

        foreach (var prefix in preferredNetworks)
        {
            var hit = candidates.FirstOrDefault(ip => ip.StartsWith(prefix, StringComparison.Ordinal));
            if (hit is not null)
            {
                return hit;
            }
        }

        return candidates.FirstOrDefault() ?? IPAddress.Loopback.ToString();
    }
}
