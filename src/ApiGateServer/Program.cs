using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Com.Ctrip.Framework.Apollo;

namespace ApiGateServer
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
                    webBuilder.ConfigureAppConfiguration((context, builder) =>
            {
                builder.SetBasePath(context.HostingEnvironment.ContentRootPath)
                .AddJsonFile("Ocelot.json");
                builder.AddApollo(builder.Build().GetSection("apollo"))
                    .AddDefault()
                    .AddNamespace("application");

            }).UseUrls(url).UseStartup<Startup>();
                });
        }
    }
}
