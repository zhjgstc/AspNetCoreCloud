using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using ApiGateServer.Filter;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.HttpsPolicy;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Ocelot.DependencyInjection;
using Ocelot.Middleware;
using Ocelot.Provider.Consul;

namespace ApiGateServer
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
            services.AddOcelot().AddConsul();
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }

            var jwtSecret = Configuration["jwt.secret"];

            var configuration = new OcelotPipelineConfiguration
            {
                AuthenticationMiddleware = async (ctx, next) =>
                {
                    LoginFilter loginFilter = new LoginFilter();
                    string json = "";
                    var flag = loginFilter.NeedLogin(ctx.HttpContext, Configuration, out json);
                    if (!flag)
                    {
                        await ctx.HttpContext.Response.WriteAsync(json);
                        return;
                    }
                    await next.Invoke();
                }
            };

            app.UseOcelot(configuration).Wait();
            app.Run(async (context) =>
            {
                await context.Response.WriteAsync("");
            });
        }
    }
}
