# .NET 微服务部署方案：K8s 版 vs 非 K8s 版

> 配套文档：`架构现代化建议-2026.md`（通用参考架构）
> 本文把「部署形态」这一层单独拆开，给出两套完整可落地的方案。
> 落地施工计划：`改造计划-非K8s版-NET10-YARP-Nacos.md`（非 K8s 版的文件级改造计划）
> 基准日：2026-10-06

---

## 一、先选哪一套

| 判断条件 | 选择 |
|---|---|
| 已有 K8s 集群 / 用云厂商托管 K8s（ACK、EKS、AKS、TKE） | **K8s 版** |
| 服务数 ≥ 8，或需要自动扩缩容、多区域、GitOps | **K8s 版** |
| 部署在少量自有服务器 / 客户内网 / 工控机 / 边缘节点 | **非 K8s 版** |
| 团队没有 K8s 运维经验，且短期不打算投入 | **非 K8s 版** |
| 交付给客户私有化部署、环境不可控 | **非 K8s 版** |
| 项目早期，只想快速验证 | **非 K8s 版**（后续可平滑迁移） |

> **默认建议**：**非 K8s 起步，架构上保持 K8s 就绪**。代码层不依赖任何部署形态，迁移时只换基础设施层。

---

## 二、共同底座（两套方案完全一样）

这部分是「与部署无关的」，无论选哪套都不变，也是投入产出比最高的部分。

| 层 | 内容 |
|---|---|
| 运行时 | .NET 10 LTS |
| 代码结构 | `Domain / Application / Infrastructure / Api` 四层 + `BuildingBlocks` + `Contracts` |
| API | Minimal APIs + OpenAPI 3.1 + Scalar + ProblemDetails |
| 数据 | Database per Service + EF Core 10 + FusionCache |
| 可观测 | OpenTelemetry → **OTLP**（这套配置在两种环境下完全一致） |
| 韧性 | `Microsoft.Extensions.Http.Resilience` |
| 安全 | OIDC/OAuth2，密钥不进 Git |
| 消息 | Wolverine 或 Rebus + Outbox |
| 本地开发 | **Aspire AppHost**（两套方案共用，Aspire 负责本地，不负责生产） |
| 镜像 | `dotnet publish` 容器化，非 root 用户运行 |

**关键设计原则**：让"服务发现"成为**可替换的抽象**。

```csharp
// 业务代码只依赖服务名，不关心背后是 K8s DNS 还是 Consul
public class CatalogClient(HttpClient http, IServiceDiscovery discovery)
{
    public async Task<ProductDto?> GetAsync(Guid id, CancellationToken ct)
        => await http.GetFromJsonAsync<ProductDto>(
            $"{await discovery.ResolveAsync("catalog")}/api/products/{id}", ct);
}
```

K8s 环境下 `IServiceDiscovery` 直接返回 `http://catalog:8080`；非 K8s 环境下查 Consul/Nacos。**业务代码零改动**。

---

## 三、K8s 版

### 3.1 拓扑

```
                    Internet
                       │
        ┌──────────────┼──────────────┐
        │        雷池 WAF（可选）      │   ← 独立部署，独立于集群
        └──────────────┼──────────────┘
                       │
        ┌──────────────▼──────────────┐
        │  Ingress / Gateway API       │   ← NGINX Ingress 或 Gateway API
        │  (TLS 终止 / 域名路由)        │
        └──────────────┬──────────────┘
                       │
        ┌──────────────▼──────────────┐
        │  YARP Gateway (Deployment)   │   ← 只做业务网关：鉴权/限流/聚合
        └──────────────┬──────────────┘
                       │  Cluster DNS: http://catalog:8080
        ┌──────────────┼──────────────┐
        ▼              ▼              ▼
   Service         Service         Service
   (catalog)       (ordering)      (identity)
        │              │              │
   Pod Pod Pod    Pod Pod Pod    Pod Pod Pod   ← HPA 自动扩缩
        │              │              │
   StatefulSet    StatefulSet     StatefulSet
   (PostgreSQL)   (PostgreSQL)    (PostgreSQL)
                       │
        ┌──────────────▼──────────────┐
        │  OTel Collector (DaemonSet)  │ → Grafana / Jaeger / 云 APM
        └─────────────────────────────┘
```

### 3.2 组件表

| 能力 | K8s 版方案 | 说明 |
|---|---|---|
| 服务发现 | **K8s Service DNS**（内置） | `http://catalog:8080` 自动解析，**不需要 Consul** |
| 负载均衡 | **K8s Service**（iptables/IPVS） | Kube-proxy 做 L4 负载，YARP 只需配单个 destination |
| 入口 | **Ingress** 或 **Gateway API** | 新项目推荐 Gateway API（Ingress 已停止演进） |
| 网关 | YARP（Deployment） | 只承担业务网关职责 |
| 配置 | **ConfigMap + Secret**；需动态推送时加 Nacos/Apollo | Reloader 或 OTel 方式热更新 |
| 密钥 | **Sealed Secrets** / **External Secrets Operator** / Vault | 不要把明文 Secret 提交到 Git |
| 扩缩容 | **HPA**（CPU/内存）/ **KEDA**（基于消息队列长度等） | — |
| 健康检查 | **liveness + readiness + startup 探针** | 三种探针分离 |
| 日志 | 容器 **stdout** → Fluent Bit / OTel Collector 采集 | 不要写文件 |
| 部署 | **Helm Chart** + **Kustomize**；GitOps 用 ArgoCD / Flux | — |
| 服务网格 | 可选 **Istio ambient** 或 **Linkerd** | 只在强合规/多团队时才上 |
| 状态服务 | **StatefulSet** + PVC，或用云托管数据库 | 生产建议直接用云托管 RDS |
| 证书 | **cert-manager** 自动签发续期 | — |

### 3.3 目录结构

```
deploy/k8s/
├── base/                     # Kustomize 基础层
│   ├── namespace.yaml
│   ├── gateway/
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   ├── hpa.yaml
│   │   └── configmap.yaml    # yarp.json
│   ├── catalog/
│   ├── ordering/
│   └── otel-collector/
├── overlays/
│   ├── dev/
│   ├── staging/
│   └── prod/
├── helm/                     # 或改用 Helm Chart
└── infra/                    # 基础设施（一次性安装）
    ├── ingress-nginx/
    ├── cert-manager/
    └── grafana/
```

### 3.4 关键 manifest

**服务 + Deployment 要点**（以 catalog 为例）：

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: catalog
spec:
  replicas: 3
  template:
    spec:
      securityContext:
        runAsNonRoot: true
        runAsUser: 10001
      containers:
        - name: catalog
          image: registry.example.com/catalog:1.4.2
          ports:
            - containerPort: 8080
          env:
            - name: OTEL_EXPORTER_OTLP_ENDPOINT
              value: http://otel-collector:4317
            - name: OTEL_SERVICE_NAME
              value: catalog
            - name: ConnectionStrings__Database
              valueFrom:
                secretKeyRef:
                  name: catalog-db
                  key: connectionString
          resources:
            requests: { cpu: 100m, memory: 256Mi }
            limits:   { cpu: 500m, memory: 512Mi }
          startupProbe:
            httpGet: { path: /health/startup, port: 8080 }
            failureThreshold: 30
            periodSeconds: 2
          readinessProbe:
            httpGet: { path: /health/ready, port: 8080 }
            periodSeconds: 5
          livenessProbe:
            httpGet: { path: /health/live, port: 8080 }
            periodSeconds: 15
---
apiVersion: v1
kind: Service
metadata:
  name: catalog
spec:
  selector: { app: catalog }
  ports:
    - port: 8080
      targetPort: 8080
```

**YARP 配置的关键差异**：K8s 里每个 Cluster 只需一个 destination，负载均衡交给 Service。

```json
{
  "ReverseProxy": {
    "Clusters": {
      "catalog": {
        "Destinations": {
          "catalog": { "Address": "http://catalog:8080" }
        }
      }
    }
  }
}
```

### 3.5 K8s 版的三个注意点

1. **不要为了"微服务"而上服务网格。** Istio 会显著提升运维复杂度，只在有明确需求（mTLS 强合规、细粒度流量治理、多团队）时才引入。Istio ambient 模式比 sidecar 模式轻，是 2026 年的更好选择。
2. **优雅停机必须做。** K8s 滚动更新会发 SIGTERM，应用要处理并在 `terminationGracePeriodSeconds` 内完成在途请求，否则每次发布都有 502。
3. **数据库尽量用云托管。** 自建 StatefulSet 数据库是最容易出事的环节（备份、故障切换、扩容都要自己做）。

---

## 四、非 K8s 版

### 4.1 拓扑

```
                       Internet
                          │
              ┌───────────▼───────────┐
              │  雷池 WAF（可选）       │
              └───────────┬───────────┘
                          │
              ┌───────────▼───────────┐
              │  Nginx / Caddy         │  TLS 终止 + 反向代理（可选）
              └───────────┬───────────┘
                          │
              ┌───────────▼───────────┐
              │  YARP Gateway  :10000  │  鉴权 / 限流 / 服务发现 / LB
              └───────────┬───────────┘
                          │  从注册中心取健康实例
        ┌─────────────────┼─────────────────┐
        ▼                 ▼                 ▼
   catalog:10100     ordering:10200    identity:10300
   (×2 实例)          (×2 实例)          (×2 实例)
        │                 │                 │
        └─────────────────┼─────────────────┘
                          │
        ┌─────────────────┴─────────────────┐
        │  注册中心 + 配置中心                │
        │  方案A: Consul + Apollo            │
        │  方案B: Nacos（推荐，二合一）        │
        └─────────────────┬─────────────────┘
                          │
        PostgreSQL  Redis  RabbitMQ  OTel Collector
```

### 4.2 组件表

| 能力 | 非 K8s 版方案 | 说明 |
|---|---|---|
| 服务发现 | **Nacos（推荐）** 或 Consul | 没有 K8s DNS，必须有注册中心 |
| 负载均衡 | **YARP 自己承担**（多 destination + RoundRobin/LeastRequests） | 或前置 Nginx/HAProxy |
| 健康检查 | 注册中心健康检查（Consul HTTP check / Nacos 心跳） | 服务要暴露 `/health` |
| 配置中心 | **Nacos**（与注册中心合一）或 Apollo | 非 K8s 下没有 ConfigMap，动态配置更依赖它 |
| 入口 | Nginx / Caddy（TLS + 反代） | 或直接暴露 YARP |
| 编排 | **docker compose**（单机/少量机器）/ systemd（无 Docker 环境） | 见 4.4 |
| 扩缩容 | 手动改 `replicas`，或用脚本/docker compose `--scale` | 没有 HPA |
| 日志 | Serilog → 文件 + OTel Collector 采集，或直接 stdout → Docker 日志驱动 | 需配置日志轮转，防磁盘撑爆 |
| 密钥 | `.env`（不进 Git）/ **Vault** / 云密钥管理 | `.env` 要加进 `.gitignore` |
| 部署 | CI 构建镜像 → 服务器 `docker compose pull && up -d` | 或 rsync + systemd |

### 4.3 注册中心选型：Nacos vs Consul

**推荐 Nacos**，理由是它一个组件同时解决服务发现 + 配置中心，比 Consul + Apollo 少一套运维。

| | Nacos | Consul + Apollo |
|---|---|---|
| 组件数 | **1 套** | 2 套 |
| 服务发现 | ✅ | ✅ |
| 配置中心 | ✅ | ✅（Apollo 治理更强） |
| .NET 客户端 | 社区维护，够用 | Consul 官方客户端成熟 |
| 部署复杂度 | 低（单 jar + MySQL） | 中（Apollo 组件多） |
| 许可 | Apache-2.0 | Consul **BUSL-1.1**（IBM），Apollo Apache-2.0 |
| 适合 | 中小规模、想省运维 | 已有 Consul 积累、或需要强配置审批流 |

> 若选 Consul，注意它已被 IBM 收购、许可为 BUSL-1.1（非严格开源），商业产品化场景需法务确认。

### 4.4 docker compose 骨架

```yaml
# deploy/compose/docker-compose.yml
services:
  gateway:
    image: registry.example.com/gateway:1.4.2
    ports: ["10000:8080"]
    environment:
      OTEL_EXPORTER_OTLP_ENDPOINT: http://otel-collector:4317
      OTEL_SERVICE_NAME: gateway
      Nacos__ServerAddress: http://nacos:8848
    depends_on: [nacos, otel-collector]
    restart: unless-stopped

  catalog:
    image: registry.example.com/catalog:1.4.2
    environment:
      OTEL_EXPORTER_OTLP_ENDPOINT: http://otel-collector:4317
      OTEL_SERVICE_NAME: catalog
      Nacos__ServerAddress: http://nacos:8848
      ConnectionStrings__Database: "Host=postgres;Database=catalog;Username=app;Password=${DB_PASSWORD}"
    depends_on:
      postgres: { condition: service_healthy }
    restart: unless-stopped
    # 扩容：docker compose up -d --scale catalog=3

  postgres:
    image: postgres:18
    environment:
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes: ["pgdata:/var/lib/postgresql/data"]
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U app"]
      interval: 5s
      retries: 10
    restart: unless-stopped

  redis:
    image: redis:8
    restart: unless-stopped

  rabbitmq:
    image: rabbitmq:4-management
    restart: unless-stopped

  nacos:
    image: nacos/nacos-server:v3
    environment:
      MODE: standalone
    ports: ["8848:8848", "9848:9848"]
    restart: unless-stopped

  otel-collector:
    image: otel/opentelemetry-collector-contrib
    volumes: ["./otel-collector-config.yml:/etc/otelcol-contrib/config.yml"]
    ports: ["4317:4317", "4318:4318"]
    restart: unless-stopped

  aspire-dashboard:        # 轻量可观测后端，适合非 K8s 环境
    image: mcr.microsoft.com/dotnet/aspire-dashboard:latest
    ports: ["18888:18888", "18889:18889"]
    environment:
      DOTNET_DASHBOARD_UNSECURED_ALLOW_ANONYMOUS: "true"
    restart: unless-stopped

volumes:
  pgdata:
```

### 4.5 非 K8s 版的四个注意点

1. **日志轮转必须配**。容器日志不设上限会撑爆磁盘：
   ```yaml
   logging:
     driver: json-file
     options: { max-size: "10m", max-file: "3" }
   ```
2. **YARP 要自己列多个 destination**。没有 K8s Service 帮你负载均衡，要么让 YARP 从注册中心动态取，要么静态列全：
   ```json
   { "Clusters": { "catalog": {
       "LoadBalancingPolicy": "RoundRobin",
       "Destinations": {
         "catalog-1": { "Address": "http://catalog-1:8080" },
         "catalog-2": { "Address": "http://catalog-2:8080" }
       } } } }
   ```
3. **优雅停机同样要做**。`docker compose down` / `restart` 会发 SIGTERM，`stop_grace_period` 默认只有 10 秒。
4. **数据库备份要自己写**。没有 Operator 帮你做，定时任务 `pg_dump` + 异地存储 + **定期恢复演练**。

---

## 五、差异对照总表

| 维度 | K8s 版 | 非 K8s 版 |
|---|---|---|
| 服务发现 | K8s Service DNS（**内置，零组件**） | Nacos / Consul（**必须额外部署**） |
| 负载均衡 | Kube-proxy（Service） | YARP 自己 + 前置 Nginx |
| 配置管理 | ConfigMap/Secret（内置） | Nacos / Apollo |
| 入口 | Ingress / Gateway API | Nginx / Caddy |
| 弹性伸缩 | HPA / KEDA（自动） | 手动 `--scale` |
| 健康检查 | K8s 三种探针 | 注册中心心跳 / HTTP check |
| 发布 | 滚动更新、金丝雀（原生） | 手工切换 / 脚本 |
| 日志 | stdout → 采集器 | 文件/Serilog + 轮转 |
| 密钥 | Sealed Secrets / Vault | .env / Vault |
| 服务网格 | 可选 Istio / Linkerd | 不建议 |
| 部署工具 | Helm / Kustomize / ArgoCD | docker compose / systemd |
| 运维门槛 | **高**（需 K8s 能力） | **低** |
| 资源开销 | 控制面有开销（小集群不划算） | 几乎为零 |
| 适用规模 | 中大型、多团队 | 中小型、私有化交付 |

---

## 六、迁移路径（非 K8s → K8s）

架构上保持可迁移的关键：**服务发现抽象 + 配置外置 + 无状态服务**。

| 步骤 | 动作 | 影响 |
|---|---|---|
| 1 | 业务代码只依赖服务名，不依赖具体注册中心 | 零改动前提 |
| 2 | 配置全部走 `IConfiguration`，不读本地文件 | 零改动前提 |
| 3 | 服务无状态（会话/缓存外置到 Redis） | 零改动前提 |
| 4 | 日志输出到 stdout | 零改动前提 |
| 5 | 迁移时替换 `IServiceDiscovery` 实现：Nacos → K8s DNS | **只改基础设施层** |
| 6 | 配置改为 ConfigMap/Secret 注入 | 只改部署层 |
| 7 | 写 Helm Chart / Kustomize manifests | 新增 |
| 8 | 下线 Nacos/Consul（如不再需要） | 减少一套中间件 |

**满足 1-4 的话，迁移工作量集中在部署层，业务代码几乎不动。**

---

## 七、给 AspNetCoreCloud 仓库的建议

作为通用参考架构，建议**两套都提供**，但明确主次：

| 版本 | 定位 | 建议 |
|---|---|---|
| **非 K8s 版** | 默认主分支 | `docker compose up` 一条命令跑起来，门槛最低，受众最广 |
| **K8s 版** | `deploy/k8s/` 目录 + 独立文档 | 提供完整 manifests，标注需要集群 |

理由：参考架构的价值之一是**让人能跑起来验证**。非 K8s 版一条命令就能验证，K8s 版需要集群，很多人跑不了。两套并存、主次分明，覆盖面最大。

目录建议：

```
AspNetCoreCloud/
├── src/                      # 业务代码（两套共用，与部署无关）
├── deploy/
│   ├── compose/              # 非 K8s 版（默认）
│   │   ├── docker-compose.yml
│   │   └── docker-compose.waf.yml   # 雷池，可选
│   └── k8s/                  # K8s 版
│       ├── base/
│       └── overlays/
└── docs/
    ├── 部署-K8s版.md
    └── 部署-非K8s版.md
```

---

## 八、双路径共存：一套 src、两套 deploy、同一份镜像

**结论：可以，而且应该这么做。** .NET 10 项目本身完全通用，差异被压缩到**三个可替换点**，其余 100% 共用。

### 8.1 共用 / 不共用清单

| 资产 | 是否共用 | 说明 |
|---|---|---|
| `src/` 全部业务代码 | ✅ **完全共用** | 一份代码，不做条件编译 |
| `BuildingBlocks/` | ✅ 共用 | K8s 与 Nacos **两个实现都在同一个程序集**，运行时选一个 |
| **容器镜像** | ✅ **同一份 image** | 差异只在注入的配置（12-factor） |
| `Dockerfile` | ✅ 共用 | 非 root、多阶段构建 |
| OTel / 健康检查 / 日志 / 熔断 | ✅ 共用 | 见 8.2 |
| `deploy/compose/` | ❌ 非 K8s 专用 | — |
| `deploy/k8s/` | ❌ K8s 专用 | — |
| 中间件依赖 | ❌ 不同 | 非 K8s 多一个 Nacos |
| 配置注入方式 | ❌ 不同 | 但**都汇入 `IConfiguration`**，业务无感 |

> 一句话：**镜像通用，路径靠配置切换。** `docker compose` 与 `kubectl apply` 拉的是同一个 tag。

### 8.2 差异只落在这三个可替换点

| # | 可替换点 | K8s 实现 | 非 K8s 实现 | 业务是否感知 |
|---|---|---|---|---|
| 1 | **服务发现** | `K8sServiceDiscovery` → 直接拼 `http://{service}:{port}` | `NacosServiceDiscovery` → 查 Nacos 健康实例 | ❌ 只依赖 `IServiceDiscovery` |
| 2 | **网关路由** | `K8sProxyConfigProvider`：静态配置，cluster 只配 **1 个** destination（LB 交给 Service） | `NacosProxyConfigProvider`：订阅变更，cluster 列出 **N 个** destination（YARP 自己 LB） | ❌ 都是 `IProxyConfigProvider` |
| 3 | **配置来源** | ConfigMap + Secret → 环境变量/挂载文件 | Nacos 配置源 + 环境变量 | ❌ 都读 `IConfiguration` / `IOptions<T>` |

### 8.3 切换方式：一个开关，装配时选实现

```csharp
// BuildingBlocks 内部封装，业务宿主只调一行
builder.Services.AddAspNetCoreCloudInfrastructure(builder.Configuration);

// 内部：
// var mode = config.GetValue<string>("Deployment:Mode");   // "k8s" | "standalone"
// mode == "k8s" ? AddK8sDiscovery() : AddNacosDiscovery(config.GetSection("Nacos"));
```

注入方式：

| 环境 | 怎么设这个开关 |
|---|---|
| compose | `environment: Deployment__Mode=standalone` |
| K8s | ConfigMap `Deployment__Mode: "k8s"` |

**不要在 `src/` 里写 `if (IsKubernetes)` 这类散落判断**——只允许出现在 `BuildingBlocks` 的装配扩展里，且只有这一处。

### 8.4 四条铁律（守住"通用"不腐化）

只要守住这四条，两套路径就永远共用同一份业务代码：

1. **只依赖服务名**，不依赖 IP/端口/注册中心
2. **配置全部走 `IConfiguration`**，不读本地文件、不读环境变量硬编码
3. **服务无状态**（会话/缓存外置 Redis）
4. **日志输出到 stdout**，由采集器接管

**用架构测试把第 1 条固化成会失败的 CI 检查**（ArchUnitNET）：

```csharp
[Fact]
public void 业务层不得引用任何注册中心实现()
{
    var rule = ArchRuleDefinition.Types()
        .That().ResideInNamespace("AspNetCoreCloud.Services..")
        .Should().NotDependOnAny("Nacos.V2", "AspNetCoreCloud.ServiceDiscovery.Nacos");
    rule.Check(Architecture);
}
```

这条测试是双路径方案的**保险丝**：哪天有人在业务代码里 `using Nacos`，CI 直接红。

### 8.5 分支策略

| 方案 | 做法 | 评价 |
|---|---|---|
| **A. 单分支双目录**（推荐） | `main` 上同时放 `deploy/compose/` 与 `deploy/k8s/`，README 给两条快速开始 | ✅ src 只有一份，不会漂移；CI 一次验证两套 |
| B. 两个长期分支 | `main`（非 K8s）+ `k8s` 分支 | ❌ src 改动要双份同步，三个月内必然漂移 |
| C. 两个仓库 | 各自独立 | ❌ 最差，成本翻倍 |

**强烈建议 A。** 若想提供"两个可下载版本"，用 **Release 附件 / tag** 打包，而不是长期分支。

### 8.6 CI 验证矩阵

```yaml
strategy:
  matrix:
    target: [compose, k8s]
steps:
  - run: dotnet build && dotnet test          # 两套都要过（含架构测试）
  - if: matrix.target == 'compose'
    run: docker compose up -d && ./scripts/smoke.sh
  - if: matrix.target == 'k8s'
    run: |
      kubectl apply --dry-run=client -k deploy/k8s/overlays/dev   # 必做
      # 可选：kind/k3s 起集群跑真冒烟
```

K8s 那条**最低限度要做 `kubectl apply --dry-run`**（零成本、能挡住 YAML 语法与字段错误）；真集群冒烟用 kind 可选。

### 8.7 K8s 路径还要不要 Nacos？

| 能力 | K8s 版建议 | 理由 |
|---|---|---|
| 服务发现 | **不用 Nacos**，用 Service DNS | 内置、零组件，再挂注册中心是冗余 |
| 配置中心 | **默认不用**（ConfigMap + Reloader）；需要动态推送/灰度/多集群才开 | 抽象已在，开关而已 |

即：K8s 版默认**零额外中间件**，这也正好演示"同一套抽象，可以什么都不接"。

### 8.8 双路径的目录结构（最终）

```
AspNetCoreCloud/
├── src/                          # 共用（.NET 10）
│   ├── BuildingBlocks/
│   │   ├── ServiceDiscovery.Abstractions/
│   │   ├── ServiceDiscovery.Nacos/      # 非 K8s 用
│   │   ├── ServiceDiscovery.K8s/        # K8s 用
│   │   └── Observability/
│   ├── Gateway/
│   │   ├── NacosProxyConfigProvider/    # 非 K8s 用
│   │   └── K8sProxyConfigProvider/      # K8s 用
│   └── Services/{Auth,Order,Product}/
├── tests/
│   └── ArchitectureTests/               # 守住"业务层不许碰 Nacos"
├── deploy/
│   ├── compose/                         # 非 K8s 路径（默认）
│   └── k8s/                             # K8s 路径
└── docs/
    ├── 部署-非K8s版.md
    └── 部署-K8s版.md
```
