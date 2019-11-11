using System;
using Consul;
using Microsoft.AspNetCore.Builder;

namespace ProductService.Extension
{
    public static class ConsulBuilderExtension
    {
        // 服务注册

        public static IApplicationBuilder RegisterConsul(this IApplicationBuilder app,  Microsoft.Extensions.Hosting.IHostApplicationLifetime lifetime,string consulServiceIP,string consulServicePort, string consulServiceName,string healthIP,string healthPort,string healthUrl)
        {
            
            var consulClient = new ConsulClient(x => x.Address = new Uri($"http://{consulServiceIP}:{consulServicePort}"));//请求注册的 Consul 地址

            var httpCheck = new AgentServiceCheck()

            {

                DeregisterCriticalServiceAfter = TimeSpan.FromSeconds(5),//服务启动多久后注册

                Interval = TimeSpan.FromSeconds(10),//健康检查时间间隔，或者称为心跳间隔

                HTTP = $"http://{healthIP}:{healthPort}:{healthUrl}",//健康检查地址

                Timeout = TimeSpan.FromSeconds(5)

            };

            // Register service with consul

            var registration = new AgentServiceRegistration()

            {

                Checks = new[] { httpCheck },

                ID = consulServiceName + "_" + healthPort,

                Name = consulServiceName,

                Address = healthIP,

                Port = Convert.ToInt32(healthPort),

                Tags = new[] { consulServiceName }//添加 urlprefix-/servicename 格式的 tag 标签，以便 Fabio 识别

            };

            consulClient.Agent.ServiceRegister(registration).Wait();//服务启动时注册，内部实现其实就是使用 Consul API 进行注册（HttpClient发起）

            lifetime.ApplicationStopping.Register(() =>
            {
                consulClient.Agent.ServiceDeregister(registration.ID).Wait();//服务停止时取消注册

            });

            return app;

        }

    }
}
