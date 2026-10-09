using System.Diagnostics;
using System.Reflection;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using OpenTelemetry.Exporter;
using OpenTelemetry.Logs;
using OpenTelemetry.Metrics;
using OpenTelemetry.Resources;
using OpenTelemetry.Trace;

namespace AspNetCoreCloud.Observability;

/// <summary>
/// 可观测统一注册入口。
///
/// 一个方法把 trace / metrics / logs 三件事接好：
/// <list type="bullet">
///   <item>入站请求、出站 HttpClient 调用自动生成 span，跨服务的 traceparent 由 SDK 自动传播；</item>
///   <item>ASP.NET Core、HttpClient、运行时指标自动采集；</item>
///   <item>ILogger 日志通过 OTLP 导出，并自动带上 traceId / spanId。</item>
/// </list>
///
/// 埋点始终开着，导出是可选的：没有配置端点时只生成数据不导出，
/// 这样本地不启收集端也不会刷一堆连接失败日志。
/// </summary>
public static class ObservabilityExtensions
{
    /// <summary>响应头里回传当前链路 TraceId，便于 curl 验证与日志串联。</summary>
    public const string TraceIdHeaderName = "X-Trace-Id";

    /// <summary>
    /// 接入 OpenTelemetry。
    /// </summary>
    /// <param name="builder">宿主构建器</param>
    /// <param name="serviceName">默认服务名，建议与注册中心里的服务名一致</param>
    /// <param name="activitySources">额外订阅的 ActivitySource（如第三方库自带的埋点源）</param>
    public static WebApplicationBuilder AddAspNetCoreCloudObservability(
        this WebApplicationBuilder builder,
        string serviceName,
        params string[] activitySources)
    {
        ArgumentNullException.ThrowIfNull(builder);

        var options = new ObservabilityOptions();
        builder.Configuration.GetSection(ObservabilityOptions.SectionName).Bind(options);

        if (!options.Enabled)
        {
            return builder;
        }

        var resolvedName = ResolveServiceName(
            options,
            builder.Configuration,
            serviceName,
            builder.Environment.ApplicationName);
        var version = string.IsNullOrWhiteSpace(options.ServiceVersion)
            ? ResolveAssemblyVersion()
            : options.ServiceVersion;

        var endpoint = ResolveEndpoint(options);
        var protocol = ResolveProtocol(options.OtlpProtocol);

        IReadOnlyList<string> excludedRequestPaths = options.ExcludedRequestPaths.Count == 0
            ? ObservabilityOptions.DefaultExcludedRequestPaths
            : options.ExcludedRequestPaths;

        IReadOnlyList<string> excludedHttpPaths = options.ExcludedHttpPaths.Count == 0
            ? ObservabilityOptions.DefaultExcludedHttpPaths
            : options.ExcludedHttpPaths;

        var openTelemetry = builder.Services
            .AddOpenTelemetry()
            .ConfigureResource(resource => resource
                .AddService(
                    serviceName: resolvedName,
                    serviceVersion: version,
                    autoGenerateServiceInstanceId: true)
                .AddAttributes(new Dictionary<string, object>
                {
                    ["deployment.environment"] = builder.Environment.EnvironmentName
                }));

        // ── Traces ────────────────────────────────────────────────
        if (options.EnableTraces)
        {
            openTelemetry.WithTracing(tracing =>
            {
                tracing
                    .AddAspNetCoreInstrumentation(instrumentation =>
                    {
                        instrumentation.RecordException = true;
                        instrumentation.Filter = context =>
                            !IsExcludedRequestPath(context.Request.Path, excludedRequestPaths);
                    })
                    .AddHttpClientInstrumentation(instrumentation =>
                    {
                        instrumentation.RecordException = true;
                        // 1.19 起属性名带上了目标类型，Filter -> FilterHttpRequestMessage
                        instrumentation.FilterHttpRequestMessage = message =>
                            !IsExcludedHttpPath(message.RequestUri, excludedHttpPaths);
                    });

                foreach (var source in activitySources)
                {
                    if (!string.IsNullOrWhiteSpace(source))
                    {
                        tracing.AddSource(source);
                    }
                }

                if (endpoint is not null)
                {
                    tracing.AddOtlpExporter(exporter => ConfigureExporter(exporter, endpoint, protocol));
                }
            });
        }

        // ── Metrics ───────────────────────────────────────────────
        if (options.EnableMetrics)
        {
            openTelemetry.WithMetrics(metrics =>
            {
                metrics
                    .AddAspNetCoreInstrumentation()
                    .AddHttpClientInstrumentation();

                if (options.EnableRuntimeMetrics)
                {
                    metrics.AddRuntimeInstrumentation();
                }

                if (endpoint is not null)
                {
                    metrics.AddOtlpExporter(exporter => ConfigureExporter(exporter, endpoint, protocol));
                }
            });
        }

        // ── Logs ──────────────────────────────────────────────────
        if (options.EnableLogs && endpoint is not null)
        {
            // 控制台日志照常输出，这里只是额外挂一个 OTLP 出口，两者互不影响。
            builder.Logging.AddOpenTelemetry(logging =>
            {
                logging.IncludeFormattedMessage = true;
                logging.IncludeScopes = true;
                logging.ParseStateValues = true;
                logging.AddOtlpExporter(exporter => ConfigureExporter(exporter, endpoint, protocol));
            });

            // 默认 Information 起步；注册中心心跳类日志降到 Warning，避免刷屏。
            builder.Logging.AddFilter<OpenTelemetryLoggerProvider>("*", LogLevel.Information);
            builder.Logging.AddFilter<OpenTelemetryLoggerProvider>("Nacos", LogLevel.Warning);

            // OTLP 导出器内部有一个 HttpClient，默认是 Information 级，
            // 会把「每批导出」的收发过程全打出来，几秒一条、非常吵。
            // 这里压到 Warning：导出真的失败时仍能看到，正常心跳不再刷屏。
            builder.Logging.AddFilter("System.Net.Http.HttpClient", LogLevel.Warning);
        }

        return builder;
    }

    private static void ConfigureExporter(OtlpExporterOptions exporter, Uri endpoint, OtlpExportProtocol? protocol)
    {
        exporter.Endpoint = endpoint;

        if (protocol is not null)
        {
            exporter.Protocol = protocol.Value;
        }
    }

    /// <summary>
    /// 服务名优先级：<c>OTEL_SERVICE_NAME</c> &gt; <c>Observability:ServiceName</c>
    /// &gt; <c>Service:Name</c>（注册中心里用的那个名字）&gt; 调用参数 &gt; 应用名。
    /// 这样链路上的节点名和注册中心的实例名天然对得上。
    /// </summary>
    private static string ResolveServiceName(
        ObservabilityOptions options,
        IConfiguration configuration,
        string defaultName,
        string? applicationName)
    {
        var fromEnvironment = Environment.GetEnvironmentVariable("OTEL_SERVICE_NAME");

        if (!string.IsNullOrWhiteSpace(fromEnvironment))
        {
            return fromEnvironment;
        }

        if (!string.IsNullOrWhiteSpace(options.ServiceName))
        {
            return options.ServiceName;
        }

        var registeredName = configuration["Service:Name"];

        if (!string.IsNullOrWhiteSpace(registeredName))
        {
            return registeredName;
        }

        return string.IsNullOrWhiteSpace(defaultName)
            ? applicationName ?? "unknown-service"
            : defaultName;
    }

    private static Uri? ResolveEndpoint(ObservabilityOptions options)
    {
        var value = options.OtlpEndpoint;

        if (string.IsNullOrWhiteSpace(value))
        {
            value = Environment.GetEnvironmentVariable("OTEL_EXPORTER_OTLP_ENDPOINT");
        }

        if (string.IsNullOrWhiteSpace(value))
        {
            return null;
        }

        return Uri.TryCreate(value, UriKind.Absolute, out var uri) ? uri : null;
    }

    private static OtlpExportProtocol? ResolveProtocol(string? configured)
    {
        var value = configured;

        if (string.IsNullOrWhiteSpace(value))
        {
            value = Environment.GetEnvironmentVariable("OTEL_EXPORTER_OTLP_PROTOCOL");
        }

        return value?.Trim().ToLowerInvariant() switch
        {
            "grpc" => OtlpExportProtocol.Grpc,
            "http" or "http/protobuf" => OtlpExportProtocol.HttpProtobuf,
            _ => null
        };
    }

    private static bool IsExcludedRequestPath(PathString path, IReadOnlyList<string> prefixes)
    {
        foreach (var prefix in prefixes)
        {
            if (string.IsNullOrWhiteSpace(prefix))
            {
                continue;
            }

            if (path.StartsWithSegments(prefix, StringComparison.OrdinalIgnoreCase))
            {
                return true;
            }
        }

        return false;
    }

    private static bool IsExcludedHttpPath(Uri? uri, IReadOnlyList<string> fragments)
    {
        if (uri is null)
        {
            return false;
        }

        foreach (var fragment in fragments)
        {
            if (string.IsNullOrWhiteSpace(fragment))
            {
                continue;
            }

            if (uri.AbsolutePath.Contains(fragment, StringComparison.OrdinalIgnoreCase))
            {
                return true;
            }
        }

        return false;
    }

    private static string ResolveAssemblyVersion()
    {
        var informational = Assembly.GetEntryAssembly()?
            .GetCustomAttribute<AssemblyInformationalVersionAttribute>()?
            .InformationalVersion;

        if (string.IsNullOrWhiteSpace(informational))
        {
            return "1.0.0";
        }

        // 去掉 +<commit hash> 后缀，只留 1.2.3 这种干净版本号
        var plus = informational.IndexOf('+');
        return plus > 0 ? informational[..plus] : informational;
    }
}
