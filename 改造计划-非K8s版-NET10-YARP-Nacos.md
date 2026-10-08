# AspNetCoreCloud 改造计划（非 K8s 版）：.NET 10 + YARP Gateway + Nacos

> 配套文档
> - `架构现代化建议-2026.md` — 通用参考架构与技术选型总纲
> - `部署方案-K8s与非K8s双版本.md` — 两套部署形态的差异对照
> - `一键启动分发方案.md` — 让别人一条命令跑起来（GHCR 预构建镜像 + 远程 compose 引用）
>
> 本文是**非 K8s 版**的落地施工计划，落到目录、文件、命令与验收标准。
> 基准日：2026-10-06 ｜ 目标运行时：.NET 10 LTS

---

## 0. 一页速览

| 项 | 内容 |
|---|---|
| **目标** | 把现有 4 个 .NET Core 3.0 工程改造为 **.NET 10 + YARP + Nacos** 的非 K8s 微服务参考实现，`docker compose up` 一条命令可跑通 |
| **核心变化** | Ocelot → **YARP**；Consul+Apollo → **Nacos（注册+配置二合一）**；zipkin4net → **OpenTelemetry/OTLP**；手写 JWT → **JwtBearer**；多 sln → **统一 sln + 中央包管理** |
| **本次做** | 运行时升级、服务注册发现抽象、YARP 动态路由、JWT 鉴权、OTel 可观测、容器编排、README 重写 |
| **本次不做** | K8s manifests、服务网格、CQRS/Event Sourcing、消息中间件（留到 M7 可选） |
| **工期** | **约 8–11 个工作日**（M0–M6 必做，M7 可选） |
| **最大风险** | Nacos 官方没有 C# SDK，社区版 `nacos-sdk-csharp` 停在 1.3.8、落后于 Nacos 3.x → 见 §6 R1，计划已内置"抽象层隔离 + 验证门禁"两道保险 |

---

## 1. 现状盘点（文件级）

### 1.1 现有工程

| 工程 | TFM | 主要依赖 | 状态 |
|---|---|---|---|
| `src/ApiGateServer` | netcoreapp3.0 | Ocelot 13.9.0-alpha、Ocelot.Provider.Consul、Consul 0.7.2.6、JWT 5.3.1、Newtonsoft.Json 12、Apollo 2.1.0 | 🔴 整体重写 |
| `src/AuthService` | netcoreapp3.0 | Consul、Apollo、zipkin4net、Exceptionless 4.4.1、Polly 7.1.1 | 🟡 保留业务，重写宿主 |
| `src/OrderService` | netcoreapp3.0 | 同上 | 🟡 同上 |
| `src/ProductService` | netcoreapp3.0 | 同上 | 🟡 同上 |
| `Exceptionless-5.0.0/` | — | 完整第三方源码副本（~20MB） | 🔴 移出仓库 |
| `apollo-quick-start-1.5.0/` | — | Apollo 快速启动包 | 🔴 删除（Nacos 取代） |

### 1.2 已确认的硬伤（改造中一并解决）

| # | 问题 | 位置 | 处理 |
|---|---|---|---|
| B1 | 健康检查 URL 拼成 `http://{ip}:{port}:{url}`，**端口后多一个冒号**，Consul 检查必然失败 | `*/Extension/ConsulBuilderExtension.cs:24` | 随 Consul 一起删掉 |
| B2 | `services.AddOcelot()` + `app.UseOcelot(configuration).Wait()`，同步阻塞异步 | `ApiGateServer/Startup.cs` | 重写为 YARP 中间件 |
| B3 | 手写 JWT 校验（`Common/JwtToken.cs` + `JWT` 包），算法混淆/签名绕过属高危区 | `ApiGateServer/` | 换 `JwtBearer` 官方中间件 |
| B4 | `consulService.GetAsync(...).Result` 同步阻塞，有死锁与线程池饥饿风险 | `OrderService/Common/ConsulService.cs` | 换 `await` + `IHttpClientFactory` |
| B5 | 4 个工程各自一个 `.sln`，无统一解决方案、无 CI | 根目录 | 建统一 sln + GitHub Actions |
| B6 | 无 Dockerfile、无 compose，跑不起来 | 根目录 | M5 补齐 |
| B7 | 把 Exceptionless 整个源码副本提交进仓库 | 根目录 | 删除，改用 OTel |

### 1.3 本地环境（已核实）

| 项 | 结果 | 影响 |
|---|---|---|
| .NET SDK | **10.0.302 已安装**（另有 8.0.423） | 可直接开工，无需装 SDK |
| Docker | **未安装** | 见 §4 M0 的"本地验证环境"三条路 |

---

## 2. 目标架构（非 K8s 版）

### 2.1 拓扑

```
                        Internet
                           │
              ┌────────────▼────────────┐
              │ 雷池 SafeLine WAF（可选） │  独立 compose，不放主流程
              └────────────┬────────────┘
                           │
              ┌────────────▼────────────┐
              │ Nginx / Caddy（可选）     │  TLS 终止
              └────────────┬────────────┘
                           │
              ┌────────────▼────────────┐
              │  YARP Gateway   :10000   │  JWT 鉴权 / 限流 / 动态路由 / LB
              └────────────┬────────────┘
                           │ 订阅 Nacos 实例变更
              ┌────────────▼────────────┐
              │  Nacos  :8848 / :9848    │  注册中心 + 配置中心（二合一）
              └────────────┬────────────┘
        ┌──────────────────┼──────────────────┐
        ▼                  ▼                  ▼
   auth:10100        order:10200        product:10300
   (可 --scale N)     (可 --scale N)      (可 --scale N)
        │                  │                  │
        └──────────────────┼──────────────────┘
                           ▼
        PostgreSQL / Redis / OTel Collector / Aspire Dashboard
```

### 2.2 组件与版本（钉死，动手前再复核一次）

| 组件 | 版本 | 说明 |
|---|---|---|
| 运行时 | **.NET 10**（SDK 10.0.302） | LTS，支持至 2028-11-14。本地已装 |
| 网关 | **Yarp.ReverseProxy 2.3.0** | MIT；仓库已迁 `dotnet/yarp`；支持 .NET 8+；2.3.0 起自带配置 JSON Schema |
| 注册/配置中心 | **Nacos Server 2.5.x**（动手前到 nacos.io 复核 2.x 最新稳定版） | 一个组件顶 Consul+Apollo；Apache-2.0。3.x 见 §6 R1 |
| Nacos 客户端 | **nacos-sdk-csharp / .AspNetCore / .Extensions.Configuration 1.3.8** | 社区维护，Apache-2.0；目标 net5.0/netstandard2.0，在 net10 上可运行但**不是原生目标** |
| 鉴权 | **Microsoft.AspNetCore.Authentication.JwtBearer**（随运行时） | 删除 `JWT 5.3.1` 手写校验 |
| 可观测 | **OpenTelemetry .NET + OTLP 导出**（钉最新稳定版） | zipkin4net / Exceptionless 全部下线 |
| 可观测后端 | `mcr.microsoft.com/dotnet/aspire-dashboard` | 非 K8s 下最轻量的 trace/metrics/log 查看器，一条容器搞定 |
| 韧性 | **Microsoft.Extensions.Http.Resilience** | 注意它**传递依赖 Polly.Core**，详见 §3.5 授权提示 |
| 缓存 | **FusionCache**（MIT）+ Redis | L1 内存 + L2 Redis，带 fail-safe 与击穿防护 |
| 数据 | PostgreSQL 18，Database per Service | 本次只在 product 服务落地示范（M6 可选） |
| 配置 | `Nacos` 作配置源 + 本地 `appsettings.json` 只留 bootstrap | — |

### 2.3 目标目录结构

```
AspNetCoreCloud/
├── global.json                       # 钉 SDK 版本
├── Directory.Build.props             # 统一 TFM / nullable / warnings
├── Directory.Packages.props          # 中央包管理（CPM），版本只写一处
├── AspNetCoreCloud.sln               # 统一解决方案（删除 4 个子 sln）
├── src/
│   ├── BuildingBlocks/
│   │   ├── ServiceDiscovery.Abstractions/   # IServiceRegistry / IServiceDiscovery
│   │   ├── ServiceDiscovery.Nacos/          # Nacos 实现（唯一依赖 SDK 的地方）
│   │   ├── ServiceDiscovery.K8s/            # K8s 实现，证明可替换（本次真的实现，不留桩）
│   │   └── Observability/                   # OTel 统一注册扩展
│   ├── Gateway/                      # YARP 网关（原 ApiGateServer）
│   │   ├── NacosProxyConfigProvider/  # 非 K8s：动态 N 个 destination
│   │   └── K8sProxyConfigProvider/    # K8s：静态 1 个 destination
│   ├── Services/
│   │   ├── AuthService/
│   │   ├── OrderService/
│   │   └── ProductService/
│   └── Contracts/                    # 服务间 DTO 契约
├── tests/
│   └── ArchitectureTests/            # 架构测试：业务层不许引用 Nacos 命名空间
├── deploy/
│   ├── compose/
│   │   ├── docker-compose.yml
│   │   ├── docker-compose.waf.yml    # 雷池，可选
│   │   └── otel-collector-config.yml
│   └── k8s/                          # 本次不动，仅占位
├── docs/
│   ├── 架构说明.md
│   └── 快速开始.md
├── scripts/
│   ├── start.sh / stop.sh
│   └── register-nacos-config.sh      # 初始化 Nacos 配置
└── .github/workflows/build.yml       # CI：restore → build → test → 镜像
```

---

## 3. 五个关键设计决策

### 3.1 决策一：服务发现必须是"可替换抽象"，不能让 Nacos 泄漏到业务代码

这是整个计划的地基。Nacos 的 .NET SDK 是全链路里**唯一有断供风险**的组件（见 §6 R1），把它关进一个实现里，风险就可控了。

```csharp
// BuildingBlocks/ServiceDiscovery.Abstractions
public interface IServiceRegistry
{
    Task RegisterAsync(ServiceRegistration registration, CancellationToken ct);
    Task DeregisterAsync(string serviceId, CancellationToken ct);
}

public interface IServiceDiscovery
{
    Task<IReadOnlyList<ServiceEndpoint>> ResolveAsync(string serviceName, CancellationToken ct);
}

public sealed record ServiceEndpoint(string Address, bool IsHttps, IReadOnlyDictionary<string,string> Metadata);
```

**业务侧只认服务名，不认注册中心：**

```csharp
public class ProductClient(HttpClient http, IServiceDiscovery discovery)
{
    public async Task<ProductDto?> GetAsync(Guid id, CancellationToken ct)
    {
        var ep = (await discovery.ResolveAsync("product", ct)).First();
        return await http.GetFromJsonAsync<ProductDto>($"{ep.Address}/api/products/{id}", ct);
    }
}
```

- 非 K8s：`ServiceDiscovery.Nacos` 查 Nacos
- K8s：`ServiceDiscovery.K8s` 直接返回 `http://product:8080`（**M2 就实现，不留桩**）
- **迁移时业务代码零改动**——这条本身就是仓库的卖点，要在 README 里明确写出来

> **这个抽象同时是"双路径共存"的地基**：K8s 版与非 K8s 版共用同一份 `src/`、同一个镜像，差异只在 `Deployment:Mode` 这一个开关上。详见 `部署方案-K8s与非K8s双版本.md` §八。

### 3.2 决策二：YARP 用 `IProxyConfigProvider` 做动态路由，而不是静态 appsettings

非 K8s 没有 kube-proxy 帮我们负载均衡，路由表必须随 Nacos 实例变化而变。做法：

```csharp
// Gateway/NacosProxyConfigProvider
internal sealed class NacosProxyConfigProvider : IProxyConfigProvider
{
    private readonly InMemoryConfigProvider _provider = new();
    private readonly INacosNamingService _naming;

    public IProxyConfig GetConfig() => _provider.GetConfig();

    // Nacos 实例变更事件 → 重建 routes/clusters → 原子替换
    private void OnInstancesChanged(string serviceName)
    {
        var instances = _naming.SelectInstances(serviceName, "DEFAULT_GROUP", healthyOnly: true);
        var (routes, clusters) = BuildFromNacos(instances);
        _provider.Update(routes, clusters);   // YARP 内部原子交换，热更新不中断
    }
}
```

注册方式（**注意：不要同时 `LoadFromConfig`**）：

```csharp
builder.Services.AddReverseProxy()
    .AddServiceDiscoveryNacos();   // 内部 AddSingleton<IProxyConfigProvider, NacosProxyConfigProvider>
```

启动时用静态 `appsettings.json` 做兜底路由（Nacos 还没连上时至少能返回 503 而不是崩），连上后切换为动态。

### 3.3 决策三：Nacos 同时做注册中心和配置中心

这一步直接砍掉两个中间件（Consul + Apollo），是本次改造**收益最大**的一刀：

| 改造前 | 改造后 |
|---|---|
| Consul（注册） + Apollo（配置，还要 MySQL 建两个库） | **Nacos 一个容器**，控制台同时管服务列表和配置 |

配置接入：

```csharp
builder.Configuration.AddNacosV2Configuration(
    builder.Configuration.GetSection("NacosConfig"));
```

**本地 appsettings.json 只留 bootstrap**（Nacos 地址、命名空间、用户名密码），业务配置全部进 Nacos，`scripts/register-nacos-config.sh` 一键初始化。

### 3.4 决策四：保留现有服务名，只做小写化

不改 `auth / order / product` 这三个名字（避免无谓 diff 和 README 大面积改写），Nacos 里注册的服务名用小写：`auth`、`order`、`product`。命名空间用 `AspNetCoreCloud` 而不是 `public`——Nacos 3.x 把默认命名空间 ID 改成了 `public`，显式指定可跨版本一致。

### 3.5 决策五：授权风险规避（这是 2026 年最容易踩的坑）

| 库 | 2026 状态 | 本次做法 |
|---|---|---|
| **MassTransit** | v9 已商业化（约 $400/月） | 本阶段不用消息中间件；M7 若引入用 Wolverine(MIT) |
| **AutoMapper** | v15+ 商业化；最后 MIT 版 14.0.0 含未修复 CVE | 不用，手写映射或用 Mapperly |
| **MediatR** | v13+ 商业化 | 不用 |
| **FluentAssertions** | v8 商业化 | 用 **AwesomeAssertions**（Apache-2.0 fork） |
| **Polly** | 采用 OSMF 维护费（2026-11-16 生效） | 仍可用；但要知道 `Microsoft.Extensions.Http.Resilience` **传递依赖 Polly.Core**，绕不开 |

> ⚠️ 计划里不要写"用微软官方 Resilience 就绕开 Polly"——绕不开，这是常见误解。合规上 Polly 仍 BSD-3，只是大厂需缴维护费。

---

## 4. 分阶段改造计划

> 每个里程碑都给了：**目标 / 改动文件 / 验收标准**。验收不过不进下一阶段。

### M0 — 工程基建（0.5–1 天）

**目标**：统一解决方案与包管理，钉死 SDK 与 TFM，建立 CI。

| 动作 | 文件 |
|---|---|
| 新建统一 sln，删除 4 个子 sln | `AspNetCoreCloud.sln`；删除 `src/*/*.sln` |
| 钉 SDK 版本 | 新建 `global.json`（`"version": "10.0.302"`） |
| 统一编译属性 | 新建 `Directory.Build.props`：`<TargetFramework>net10.0</TargetFramework>`、`<Nullable>enable</Nullable>`、`<TreatWarningsAsErrors>true</TreatWarningsAsErrors>`、`<ImplicitUsings>enable</ImplicitUsings>` |
| 中央包管理 | 新建 `Directory.Packages.props`，所有 `PackageReference` 去掉 Version |
| 清理仓库 | 删除 `Exceptionless-5.0.0/`、`apollo-quick-start-1.5.0/`、`架构图.png`（改放 `docs/`） |
| CI | 新建 `.github/workflows/build.yml`：restore → build → test |
| 本地验证环境 | **三选一**：① 装 Docker Desktop；② `brew install colima` + `colima start`（轻量，推荐）；③ 不装容器，Nacos 用 `java -jar` 本地起（需 JDK 17+），服务用 `dotnet run` |

**验收**：`dotnet build AspNetCoreCloud.sln` 通过（此时 4 个工程仍为 netcoreapp3.0，会因 TFM 报错 → 这正说明进入 M1）。

> 建议：**M0 与 M1 合并做**，M0 单独做没有可运行产出。

---

### M1 — 运行时升级到 .NET 10（1.5–2 天）

**目标**：4 个工程跑在 net10.0 上，清掉所有 EOL 依赖，宿主改为 Minimal Hosting。

| 动作 | 涉及文件 |
|---|---|
| TFM `netcoreapp3.0` → `net10.0` | 4 个 `.csproj` |
| 删除依赖：`Ocelot*`、`Consul`、`Com.Ctrip.Framework.Apollo.Configuration`、`zipkin4net*`、`Exceptionless.AspNetCore`、`JWT`、`Newtonsoft.Json`（换 System.Text.Json）、`Polly`（换 Resilience） | 4 个 `.csproj` |
| `Startup.cs` + `Program.cs` 合并为单个 `Program.cs`（Minimal Hosting） | 4 个工程；删除全部 `Startup.cs` |
| 删除 `Extension/ConsulBuilderExtension.cs`、`Extension/ZipkinExtension.cs`、`Common/ConsulService.cs`、`Common/JwtToken.cs`、`Filter/LoginFilter.cs` | 4 个工程 |
| Controller 保留，但去掉 `.Result` 同步阻塞，改 `async/await` | `OrderService/Controllers/HomeController.cs` 等 |
| 统一响应结构与 ProblemDetails（.NET 10 默认 RFC 9457） | 新增 `BuildingBlocks/Http/` |

**升级注意点**（netcoreapp3.0 → net10 跨 7 个大版本，逐条处理）：
- `IHostBuilder` + `ConfigureWebHostDefaults` → `WebApplication.CreateBuilder`
- `services.AddControllers()` 保留，但 `Startup` 模式废弃
- `Newtonsoft.Json` → `System.Text.Json`（`JsonSerializerOptions` 差异）
- `app.UseMvc()` 若存在必须删
- `IWebHostEnvironment` 命名空间不变，但 `Microsoft.AspNetCore.Hosting` 部分类型已移到 `Microsoft.Extensions.Hosting`

**验收**：`dotnet build` 零警告；`dotnet run` 四个服务各自能起，`/home/health` 返回 200。

---

### M2 — BuildingBlocks：注册发现抽象 + Nacos 实现（2 天）⭐ 核心

> **状态：已完成（2026-10-07）。** 本次只做非 K8s 路径，`ServiceDiscovery.K8s` / `K8sProxyConfigProvider`
> / `tests/ArchitectureTests` 按约定推迟到非 K8s 全部完成后再补。

**目标**：服务能自动注册到 Nacos、能被发现、停机自动摘除。

| 动作 | 文件 |
|---|---|
| 新建抽象层 | `src/BuildingBlocks/ServiceDiscovery.Abstractions/`：`IServiceRegistry`、`IServiceDiscovery`、`ServiceEndpoint`、`ServiceRegistration` |
| 新建 Nacos 实现（**唯一依赖 nacos-sdk-csharp 的地方**） | `src/BuildingBlocks/ServiceDiscovery.Nacos/`：`NacosServiceRegistry`、`NacosServiceDiscovery`、`ServiceCollectionExtensions` |
| K8s 实现（**本次就写，不留桩**） | `src/BuildingBlocks/ServiceDiscovery.K8s/`：`K8sServiceDiscovery`（返回 `http://{name}:{port}`） |
| 注册/注销生命周期 | `IHostApplicationLifetime.ApplicationStarted` 注册、`ApplicationStopping` 注销；`IHostedService` 封装 |
| 健康检查端点 | 每个服务 `MapHealthChecks("/health/ready")` 等三态 |
| HttpClient 集成 | `AddServiceDiscoveryHttpClient("product")` → 自动解析地址 + Resilience |

**Nacos 注册的关键配置**（容器网络下极易踩坑）：

```json
{
  "Nacos": {
    "ServerAddresses": ["http://nacos:8848"],
    "Namespace": "AspNetCoreCloud",
    "UserName": "nacos",
    "Password": "nacos",
    "ServiceName": "product",
    "GroupName": "DEFAULT_GROUP",
    "Ephemeral": true,
    "NamingUseRpc": true,
    "PreferredNetworks": "10.,172.,192.168."   // ← 关键：否则可能注册成 127.0.0.1
  }
}
```

> **`PreferredNetworks` 必须配**。默认取到的可能是容器回环地址，网关拿到 `127.0.0.1` 会全部打不通。这是非 K8s + 容器场景下最常见的注册失败原因。

**验收**：
1. 起 Nacos → 控制台能看到 `auth / order / product` 三个服务
2. `docker compose up -d --scale product=3` → Nacos 里 product 有 3 个健康实例
3. `docker compose stop product-1` → 5 秒内实例消失
4. **断网测试**：kill Nacos 容器，服务仍能靠本地缓存调用（Nacos 客户端有本地缓存）

#### M2 实测记录：与计划的 3 处偏差（2026-10-07）

联网实测（本地 3 个 .NET 10 服务 → 远程 Nacos 2.5.4）后发现 3 个假设不成立，已修正：

| # | 计划里的假设 | 实测结论 | 现在的做法 |
|---|---|---|---|
| **D1** | 配 `Nacos:PreferredNetworks` 就能选对网卡 | **这个配置项根本不存在**。`NacosSdkOptions` 里没有它 —— 那是 Java / Spring Cloud Alibaba 客户端的概念 | 自己写 `LocalIpResolver`：按前缀列表（默认 `192.168.` / `10.` / `172.`）从网卡里挑，支持 `Nacos:Ip` 显式指定 |
| **D2** | `NamingUseRpc: true`（Nacos 2.x 推荐 gRPC） | **握手失败**：`Request nacos server failed: -401, Client not connected, current status: STARTING`。服务端 9848/9849 都在监听、无拒绝记录，判定为 SDK 1.3.10 与 Nacos 2.5.4 的 gRPC 不兼容 | `NamingUseRpc` 默认 **false**（HTTP 模式）。门禁验证四步全通 |
| **D3** | 端口写在 `Nacos:Port` | 与 `Urls` 两处维护同一个数字必然漂移 —— 首轮实测直接注册成了 `:80` | 从 Kestrel 的 `Urls` 配置推导（`ListeningPortResolver`），`Nacos:Port` 只作显式覆盖 |

**已知限制（不影响功能）**：`nacos-sdk-csharp` 的 `PushReceiver` 在固定 UDP 端口监听，
同一台机器跑多个进程时，后启动的会报 `Address already in use`。
只影响 UDP 推送（变更通知），HTTP 轮询照常工作，实例上下线仍能感知。
真实部署（一容器一实例 / 一机一实例）不会遇到。

**M2 验收实测结果**：

```
服务注册     auth/order/product 三个服务均出现在 Nacos，IP 与端口正确（10100/10200/10300）
跨服务调用   order -> auth [200]，order -> product [200]（全程经 IServiceDiscovery 解析）
多实例       再起一个 product 实例 → Nacos 出现 2 个健康实例
客户端 LB    order 连调 product 6 次 → 10300 命中 3 次、10301 命中 3 次
实例摘除     kill 掉 10301 → 8 秒内从 Nacos 消失，后续 6 次调用全部落到 10300
健康端点     /health、/health/live、/health/ready 三态均 200
编译         dotnet build 0 警告 0 错误
```

---

### M3 — YARP 网关（2 天）⭐ 核心

**目标**：网关从 Nacos 动态取实例，JWT 鉴权 + 限流，热更新不中断。

| 动作 | 文件 |
|---|---|
| 新建网关工程 | `src/Gateway/`（原 `ApiGateServer` 改名并重写） |
| Nacos 动态配置提供器 | `src/Gateway/NacosProxyConfigProvider/NacosProxyConfigProvider.cs`（实现 `IProxyConfigProvider`，内部用 `InMemoryConfigProvider`） |
| 路由构建 | 约定式：`/api/{service}/**` → 服务名 `{service}`；支持在 Nacos 配置里覆盖 |
| JWT 鉴权 | `AddAuthentication(JwtBearer)` + `AddAuthorization`；白名单放配置 |
| 限流 | .NET 内置 `AddRateLimiter`（固定窗口 + 按 IP 策略），替换 Ocelot 的 `RateLimitOptions` |
| 熔断/重试 | `AddServiceDiscoveryHttpClient` 里挂 Resilience：重试 + 熔断 + 超时 |
| 兜底静态路由 | `appsettings.json` 的 `ReverseProxy` 段（Nacos 不可用时的最小路由） |
| 可观测 | `.AddOpenTelemetry()` 挂到 YARP（YARP 有内置 Activity 埋点） |

**YARP 配置的非 K8s 差异**（务必写进文档）：K8s 里每个 cluster 只配一个 destination（交给 Service 负载）；**非 K8s 必须把 Nacos 返回的全部实例列为 destination**：

```csharp
var destinations = instances.ToDictionary(
    i => $"{i.InstanceId}",
    i => new DestinationConfig { Address = $"http://{i.Ip}:{i.Port}" });

new ClusterConfig {
    ClusterId = serviceName,
    LoadBalancingPolicy = "RoundRobin",       // 或 LeastRequests
    HealthCheck = new() { Active = new() { Enabled = true, Path = "/health/ready" } },
    Destinations = destinations
}
```

**验收**：
1. `curl http://localhost:10000/api/product/home` → 返回 product 服务数据
2. 不带 token 访问受保护路由 → **401**；带 token → **200**
3. `--scale product=3` 后**不用重启网关**，请求轮询到 3 个实例（日志里能看到不同实例 ID）
4. 停掉一个实例 → 网关 5 秒内不再转发给它（YARP 主动健康检查生效）

#### M3 实测记录（2026-10-08，连远程 Nacos 45.113.3.57:8848 真跑）

**验收结果**

| 项 | 结果 |
|---|---|
| `/api/product/test` 无 token | **401** |
| 带 Bearer token | **200**（返回 `123`） |
| 匿名白名单 `/api/auth/**` | **200**（无需 token） |
| 跨服务链路 order → auth/product（经网关） | **200** |
| 第二实例上线 → 网关感知 | **5 秒内**，revision 变化 |
| 连调 8 次负载均衡 | `10300 10301 10300 10301 10300 10301 10300 10301`（RoundRobin 4:4） |
| kill 实例 → 摘除 | **10 秒内**，之后 6 次全落存活实例 |
| 限流（200/秒·IP） | 250 次突发 → 199×200 + **51×429**，窗口重置后恢复 200 |
| 健康端点 | `/health`、`/health/live`、`/health/ready` 全 200 |

**实测发现并已修正的 3 个坑**

- **D4｜SDK 订阅缓存跨公网不更新（最隐蔽）**
  `SelectInstances(..., subscribe: true)` 走本地缓存，缓存靠服务端 **UDP 推送**刷新。
  跨公网/NAT 时推送到不了客户端 —— 实测注册中心上明明有 2 个实例，网关 **30 秒**内始终只看到 1 个。
  → 新增 `Nacos:UseSubscribeCache`（默认 `true`）；**网关必须设 `false`**，
  每次直查注册中心。网关是路由决策方，宁可多几个请求也要拿最新实例。

- **D5｜注册端口取了配置值而不是真实监听端口**
  原先在 `AddNacosServiceDiscovery` 里就用 `configuration["Urls"]` 预填 `options.Port`，
  于是 `options.Port > 0` 恒成立，Kestrel 真实监听地址永远不会被采用。
  后果：第二实例 `--urls 10301` 启动，却注册成配置里的 **10300**，
  与第一个实例同 ip:port，被注册中心当成同一个实例 → 永远只有 1 个实例。
  → 去掉预填；端口优先级改为「显式 `Nacos:Port` > Kestrel 实际监听地址 > 配置 `Urls` > 80」。

- **D6｜配置绑定器对集合属性是「追加」不是「替换」**
  两个实例：`GatewayOptions.Services` 默认 3 项 + 配置 3 项 = **6 项**（会产生重复路由）；
  `NacosDiscoveryOptions.ServerAddresses` 默认 `localhost:8848` + 配置的真实地址 = **2 项**
  （SDK 会一直去连一个不存在的 localhost:8848）。
  → **凡是集合类型的配置属性，默认值一律留空**，缺省值在代码里兜底。

**本次未做（顺延）**
- 熔断/重试：YARP 只能通过自定义 `IForwarderHttpClientFactory` 插入 `DelegatingHandler`，
  `ConfigureHttpClient` 只能改 `HttpClientHandler`。留到弹性专项做。
- OTel 埋点：属 M4。

---

### M4 — 可观测性（1 天）

**目标**：一条命令看到全部 trace/metrics/logs。

| 动作 | 文件 |
|---|---|
| 统一 OTel 注册扩展 | `src/BuildingBlocks/Observability/`：一次 `AddAspNetCoreCloudObservability()` 搞定 trace+metrics+logging |
| OTLP 导出 | 环境变量 `OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector:4317`、`OTEL_SERVICE_NAME` |
| 后端 | `otel-collector` + `aspire-dashboard`（非 K8s 最省事的组合） |
| 日志 | Serilog → stdout（容器场景）+ 结构化字段；**本地开发可同时输出到控制台** |
| 三态健康检查 | `/health/live`、`/health/ready`、`/health/startup` |

**验收**：Aspire Dashboard 里能看到一条 `gateway → product` 的完整链路（含 span 层级），错误请求带 traceId。

---

### M5 — 容器化与编排（1.5 天）

**目标**：`docker compose up` 一条命令跑起来全套。

| 动作 | 文件 |
|---|---|
| 多阶段 Dockerfile | 每个服务一个 `Dockerfile`（`build` → `publish` → `runtime`），**非 root 用户运行** |
| 主 compose | `deploy/compose/docker-compose.yml`：gateway + 3 服务 + nacos + postgres + redis + otel-collector + aspire-dashboard |
| Nacos 数据持久化 | standalone 模式挂 volume；生产文档里注明要改 cluster + 外置 MySQL |
| **日志轮转** | 每个服务加 `logging: { driver: json-file, options: { max-size: "10m", max-file: "3" } }` ← 不配会撑爆磁盘 |
| **优雅停机** | `stop_grace_period: 30s`（默认只有 10 秒，SIGTERM 处理不完） |
| 健康依赖 | `depends_on: { condition: service_healthy }` |
| **不要写 `container_name`** | 否则 `--scale` 会因名字冲突失败 |
| 启动/停止脚本 | `scripts/start.sh`、`scripts/stop.sh` |
| 雷池（可选） | `deploy/compose/docker-compose.waf.yml`，独立文件，README 标注"可选·生产边缘层" |
| **一键分发约束** | compose 里**只写 `image:` 不写 `build:`**、变量全给默认值、不挂本地相对路径——否则远程引用失效。详见 `一键启动分发方案.md` |

**验收**：`docker compose up -d` → 全部容器 healthy → `curl` 通 → `docker compose down` 后 Nacos 里实例已注销（无残留脏实例）。

---

### M6 — 文档与示例（1 天）

**目标**：README 从"劝退项"变成"门面"。

| 动作 | 文件 |
|---|---|
| README 重写 | 架构图 → 徽章 → 30 秒启动 → 效果截图 → 组件说明 → 边界对比表 |
| 快速开始 | `docs/快速开始.md`：一条命令 + 验证步骤 |
| 架构说明 | `docs/架构说明.md`：含"WAF vs 网关"职责对比表、"Nacos vs Consul+Apollo"选型表 |
| 服务发现可替换性 | 单独一节证明"业务代码零改动可迁 K8s" |
| Nacos 配置初始化 | `scripts/register-nacos-config.sh` |

**README 开头必须换掉的内容**（现状是 Apollo SQL 导入说明 + 百度网盘链接 + 内网 IP `192.168.31.185`，访客 30 秒内就关页面）。

> 数据层（EF Core + PostgreSQL，Database per Service）列为 **M6 可选**：只在 `product` 服务落地一次作为示范，其余服务保持内存实现，避免工期膨胀。

---

### M7 — 可选增强（按需）

| 项 | 说明 |
|---|---|
| 消息 + Outbox | RabbitMQ 4 + Wolverine(MIT) 实现 Outbox，演示跨服务最终一致 |
| 雷池 WAF | 独立 compose，见上文 M5 |
| K8s 版 | `deploy/k8s/` manifests，验证"业务代码零改动"的迁移承诺 |
| 架构测试 | ArchUnitNET：把"Domain 不许依赖 Infrastructure"固化成会失败的测试 |

---

## 5. 文件级改动总表

| 现状路径 | 动作 | 去向 |
|---|---|---|
| `src/ApiGateServer/**` | 🔴 重写 | `src/Gateway/`（YARP + Nacos 动态配置） |
| `src/AuthService/**` | 🟡 改造 | `src/Services/AuthService/` |
| `src/OrderService/**` | 🟡 改造 | `src/Services/OrderService/` |
| `src/ProductService/**` | 🟡 改造 | `src/Services/ProductService/` |
| `*/Startup.cs` | 🔴 删除 | 合并进 `Program.cs` |
| `*/Extension/ConsulBuilderExtension.cs` | 🔴 删除 | 由 `ServiceDiscovery.Nacos` 取代 |
| `*/Extension/ZipkinExtension.cs` | 🔴 删除 | 由 `BuildingBlocks/Observability` 取代 |
| `OrderService/Common/ConsulService.cs` | 🔴 删除 | 由 `IServiceDiscovery` + `IHttpClientFactory` 取代 |
| `ApiGateServer/Common/JwtToken.cs` | 🔴 删除 | 由 JwtBearer 中间件取代 |
| `ApiGateServer/Filter/LoginFilter.cs` | 🔴 删除 | 由 AuthorizationPolicy 取代 |
| `ApiGateServer/Ocelot.json` | 🔴 删除 | 由 Nacos 动态路由 + 兜底 `ReverseProxy` 段取代 |
| `*/appsettings.json` | 🟡 精简 | 只留 bootstrap |
| `src/**/*.sln` ×4 | 🔴 删除 | 统一 `AspNetCoreCloud.sln` |
| `Exceptionless-5.0.0/` | 🔴 删除 | — |
| `apollo-quick-start-1.5.0/` | 🔴 删除 | — |
| `架构图.png` | 🟡 移动 | `docs/` 并更新 |
| `README.md` | 🔴 重写 | 见 M6 |
| — | 🟢 新增 | `global.json`、`Directory.Build.props`、`Directory.Packages.props` |
| — | 🟢 新增 | `src/BuildingBlocks/*`（抽象层 + Nacos 实现 + K8s 实现 + Observability） |
| — | 🟢 新增 | `src/Contracts/`、`deploy/compose/*`、`scripts/*`、`.github/workflows/build.yml` |

---

## 6. 风险清单与对策

| # | 风险 | 影响 | 对策 |
|---|---|---|---|
| **R1** | **Nacos 无官方 C# SDK**。社区 `nacos-sdk-csharp` 停在 1.3.8（net5.0/netstandard2.0），**落后于 Nacos 3.x**。而 Nacos 3.0 拆了控制台（独立 8080 端口）、默认开启鉴权、默认命名空间 ID 改为 `public` | 高：选 3.x 可能注册/登录失败 | ① **Nacos Server 钉 2.5.x**（与 SDK 同代），3.x 列为可选并在文档注明；② 抽象层隔离，**换实现不动业务**；③ M2 第一天先做**验证门禁**：起 Nacos → 注册 → 发现 → 变更订阅，四步跑通才继续；④ 兜底方案：SDK 不通时改用 Nacos **HTTP OpenAPI v2** 自己写一个薄客户端（注册 + 心跳 + 订阅三个接口即可） |
| **R2** | 容器网络下注册 IP 错误（注册成 `127.0.0.1` 或宿主机 IP） | 高：网关全部转发失败 | 配 `PreferredNetworks`；M2 验收里加"打印注册上去的 IP 并 curl 验证" |
| R3 | netcoreapp3.0 → net10 跨 7 个大版本，API 破坏性变更多 | 中 | 逐工程升级（`dotnet build` 报错逐个修）；先升一个服务做样板再推广 |
| R4 | YARP 动态配置更新时的并发与内存快照 | 中 | 用 `InMemoryConfigProvider.Update()` 原子替换；不要在事件回调里做阻塞 I/O |
| R5 | 本机无 Docker，M2–M5 无法端到端验证 | 中 | M0 三选一装 Colima（推荐）或 Docker Desktop；或 Nacos 用 `java -jar` 直起 |
| R6 | `nacos-sdk-csharp` 依赖较老的 `Microsoft.Extensions.*`，可能与 net10 有版本冲突 | 中 | CPM 里单独放宽；必要时在 Nacos 实现工程里做版本隔离 |
| R7 | 授权合规：误用已商业化的库 | 中 | §3.5 清单逐项核对；CI 加 `dotnet list package --vulnerable --include-transitive` |
| R8 | Nacos standalone 用内置 Derby，重启丢数据 | 低 | demo 可接受；文档注明生产要 cluster + 外置 MySQL |

---

## 7. 验收标准（Definition of Done）

整套改造完成的硬指标，逐条打勾才算完：

- [ ] `dotnet build AspNetCoreCloud.sln` 零错误零警告（TFM 全部 `net10.0`）
- [ ] `docker compose up -d` 一条命令，全部容器 healthy
- [ ] Nacos 控制台能看到 `auth / order / product` 三个服务
- [ ] `curl http://localhost:10000/api/product/home` 返回 200 与业务数据
- [ ] 受保护路由无 token → 401；有 token → 200
- [ ] `docker compose up -d --scale product=3` 后**不重启网关**，流量轮询到 3 个实例
- [ ] 停掉其中一个实例，5 秒内不再有流量打到它
- [ ] Aspire Dashboard 能看到 `gateway → product` 完整链路
- [ ] `docker compose down` 后 Nacos 无残留实例
- [ ] 业务代码中 grep 不到 `Nacos.` / `Consul.` / `Ocelot.` 命名空间（只出现在 BuildingBlocks）
- [ ] README 开头 30 秒内能看懂架构并跑起来
- [ ] CI 绿标

---

## 8. 工期估算与动手顺序

| 里程碑 | 内容 | 工期 |
|---|---|---|
| M0+M1 | 基建 + .NET 10 升级 | 2–3 天 |
| M2 | 注册发现抽象 + Nacos 实现（**含验证门禁**） | 2 天 |
| M3 | YARP 网关 + 动态路由 + JWT + 限流 | 2 天 |
| M4 | OpenTelemetry + Aspire Dashboard | 1 天 |
| M5 | Docker 化 + compose 编排 | 1.5 天 |
| M6 | 文档与 README | 1 天 |
| **合计（M0–M6）** | | **9.5–11.5 天** |
| M7（可选） | Outbox / 雷池 / K8s 版 | 按需 |

**建议动手顺序**：**M0+M1 → M2 → M3 → M5 → M4 → M6**

> 把 M5（容器化）提到 M4（可观测）之前的理由：M2/M3 的验收（scale、实例摘除）都依赖 compose 环境，先把环境立起来才能验核心功能；可观测性可以在环境就绪后一次性接好。

**第一步最小动作（今天就能做）**：
1. 建 `AspNetCoreCloud.sln`，把 `ProductService` 单独升到 `net10.0` 跑通（做样板）
2. 同时起一个 Nacos 容器，**先验证 `nacos-sdk-csharp` 能否注册成功**（R1 门禁）

这两步能同时消掉 R1 和 R3 两个最高风险，后面的路就清楚了。
