using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Com.Ctrip.Framework.Apollo;
using Com.Ctrip.Framework.Apollo.ConfigAdapter;
using Com.Ctrip.Framework.Apollo.Enums;

namespace AuthService
{
    public class Program
    {
        public static void Main(string[] args)
        {

            CreateHostBuilder(args).Build().Run();
        }

        public static IHostBuilder CreateHostBuilder(string[] args)
        {
            var configuration = new ConfigurationBuilder().SetBasePath(Environment.CurrentDirectory)
                                          .AddJsonFile("appsettings.json")
                                          .Build();
            var url = $"http://*:" + configuration["Port"];

            return Host.CreateDefaultBuilder(args)
                            .ConfigureWebHostDefaults(webBuilder =>
                            {
                                webBuilder.ConfigureAppConfiguration(builder =>
                                {
                                    builder //普通方式，一般配置在appsettings.json中
                                    .AddApollo(builder.Build().GetSection("apollo"))
                                    .AddDefault()
                                    .AddNamespace("application");
                                }
                                ).UseUrls(url).UseStartup<Startup>();
                            });

        }


    }
}
