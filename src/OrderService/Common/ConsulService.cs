using System;
using System.Linq;
using System.Net.Http;
using System.Threading.Tasks;
using Consul;
using Microsoft.Extensions.Configuration;
using zipkin4net.Transport.Http;

namespace OrderService.Common
{
    public class ConsulService
    {
        private IConfiguration _configuration;
        public ConsulService(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        public async Task<string> GetAsync(string serviceName,string url)
        {
            string content = "";
            using (var consulClient = new ConsulClient(c => c.Address = new Uri($"http://{_configuration["consul.address"]}:{_configuration["consul.port"]}")))
            {
                var services = consulClient.Agent.Services().Result.Response.Values
                .Where(s => s.Service.Equals(serviceName, StringComparison.OrdinalIgnoreCase));
                if (!services.Any())
                {
                    Console.WriteLine("找不到服务的实例");
                    return content;
                }
                else
                {
                    // services.ElementAt(1);//如果环境中有多台服务器注册服务时我们可以使用随机数的方式，使用下标进行随机抽取一台服务进行使用
                    //集群中也可以轮训，当服务器性能差不多的时候可以轮着来
                    var service = services.ElementAt(Environment.TickCount % services.Count());
                    using (System.Net.Http.HttpClient http = new HttpClient(new TracingHandler(_configuration["AppName"] + "_" + Utils.LocalNetWorkIP())))
                    {
                        using (var HttpContent = new StringContent("", System.Text.Encoding.UTF8, "application/json"))
                        {
                            var ss = http.GetAsync($"http://{service.Address}:{service.Port}/{url}");
                            var result = ss.Result.Content;
                            content = await result.ReadAsStringAsync();
                        }
                    }
                    Console.WriteLine($"{service.Address}:{service.Port}");
                }

            }
            return content;
        }

        public async Task<string> PostAsync(string serviceName, string url,string param)
        {
            string content = "";
            using (var consulClient = new ConsulClient(c => c.Address = new Uri($"http://{_configuration["consul.address"]}:{_configuration["consul.port"]}")))
            {
                var services = consulClient.Agent.Services().Result.Response.Values
                .Where(s => s.Service.Equals(serviceName, StringComparison.OrdinalIgnoreCase));
                if (!services.Any())
                {
                    Console.WriteLine("找不到服务的实例");
                    return content;
                }
                else
                {
                    // services.ElementAt(1);//如果环境中有多台服务器注册服务时我们可以使用随机数的方式，使用下标进行随机抽取一台服务进行使用
                    //集群中也可以轮训，当服务器性能差不多的时候可以轮着来
                    var service = services.ElementAt(Environment.TickCount % services.Count());
                    using (System.Net.Http.HttpClient http = new HttpClient(new TracingHandler(_configuration["AppName"] + "_" + Utils.LocalNetWorkIP())))
                    {
                        using var HttpContent = new StringContent(param, System.Text.Encoding.UTF8, "application/json");
                        var ss = http.PostAsync($"http://{service.Address}:{service.Port}/{url}", HttpContent);
                        var result = ss.Result.Content;
                        content = await result.ReadAsStringAsync();
                    }
                    Console.WriteLine($"{service.Address}:{service.Port}");
                }

            }
            return content;
        }
    }
}
