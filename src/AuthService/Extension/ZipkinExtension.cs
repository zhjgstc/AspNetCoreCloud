using System;
using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using zipkin4net;
using zipkin4net.Middleware;
using zipkin4net.Tracers.Zipkin;
using zipkin4net.Transport.Http;

namespace AuthService.Extension
{
    public static class ZipkinExtension
    {
        public static void UserZipkinCore(this IApplicationBuilder app, IHostApplicationLifetime applicationLifetime, ILoggerFactory loggerFactory,string zipKinControllerUrl,string serviceName)
        {
            applicationLifetime.ApplicationStarted.Register(() =>
            {
                TraceManager.SamplingRate = 1.0f;
                var logger = new TracingLogger(loggerFactory, "zipkin4net");
                var httpsender = new HttpZipkinSender(zipKinControllerUrl, "application/json");
                var tracer = new ZipkinTracer(httpsender, new JSONSpanSerializer());
                TraceManager.RegisterTracer(tracer);
                TraceManager.Start(logger);
            });
            applicationLifetime.ApplicationStopped.Register(() => TraceManager.Stop());
            app.UseTracing(serviceName);
        }
    }
}
