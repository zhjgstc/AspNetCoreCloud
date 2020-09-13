using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.HttpsPolicy;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using OrderService.Common;
using OrderService.Extension;
using Exceptionless;
using zipkin4net.Transport.Http;

namespace OrderService
{
    public class Startup
    {
        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;
        }

        public IConfiguration Configuration { get; }

        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {
                        services.AddHttpClient("Tracer").AddHttpMessageHandler(provider => TracingHandler.WithoutInnerHandler(provider.GetService<IConfiguration>()["AppName"]));
            services.AddControllersWithViews();
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IWebHostEnvironment env, IHostApplicationLifetime lifetime, ILoggerFactory loggerFactory)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }
            else
            {
                app.RegisterConsul(lifetime, Configuration["consul.address"], Configuration["consul.port"], Configuration["AppName"], "localhost", Configuration["Port"], $"/home/health");
            }

            app.UserZipkinCore(lifetime, loggerFactory, Configuration["zipkin.address"], Configuration["AppName"] + "_" + Utils.LocalNetWorkIP());



            ExceptionlessClient.Default.Configuration.ApiKey = "B306vtrOuQ7EcMaP3po8myfYtv0nMu7iHFEACL7l";
            ExceptionlessClient.Default.Configuration.ServerUrl = "http://192.168.31.185:5000";
            app.UseExceptionless();

            
            app.UseHttpsRedirection();
            app.UseStaticFiles();

            app.UseRouting();

            app.UseAuthorization();

            app.UseEndpoints(endpoints =>
            {
                endpoints.MapControllerRoute(
                    name: "default",
                    pattern: "{controller=Home}/{action=Index}/{id?}");
            });
        }
    }
}
