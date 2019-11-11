using System;
using System.Linq;

namespace OrderService.Common
{
    public class Utils
    {
        /// <summary>
        /// 获取本机ip
        /// </summary>
        /// <returns></returns>
        public static string LocalNetWorkIP()
        {
            return System.Net.NetworkInformation.NetworkInterface.GetAllNetworkInterfaces()
  .Select(p => p.GetIPProperties())
  .SelectMany(p => p.UnicastAddresses)
  .Where(p => p.Address.AddressFamily == System.Net.Sockets.AddressFamily.InterNetwork && !System.Net.IPAddress.IsLoopback(p.Address))
  .FirstOrDefault()?.Address.ToString();

        }
    }
}
