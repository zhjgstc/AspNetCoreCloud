using System.Diagnostics;
using Microsoft.AspNetCore.Builder;

namespace AspNetCoreCloud.Observability;

/// <summary>
/// 把当前链路的 TraceId 回写到响应头。
/// 排查问题时 <c>curl -i</c> 就能拿到 traceId，再拿它去日志或看板里搜，不用猜。
/// </summary>
public static class TraceIdResponseHeaderExtensions
{
    public static IApplicationBuilder UseTraceIdResponseHeader(this IApplicationBuilder app)
    {
        ArgumentNullException.ThrowIfNull(app);

        app.Use(async (context, next) =>
        {
            var activity = Activity.Current;

            if (activity is not null && !context.Response.Headers.ContainsKey(ObservabilityExtensions.TraceIdHeaderName))
            {
                context.Response.Headers[ObservabilityExtensions.TraceIdHeaderName] = activity.TraceId.ToString();
            }

            await next();
        });

        return app;
    }
}
