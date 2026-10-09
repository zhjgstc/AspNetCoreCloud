# 构建上下文 = 仓库根目录（重要）：
#   docker build -f src/Gateway/Dockerfile -t aspnetcorecloud-gateway:latest .
#
# 三段式：还原 → 发布 → 运行时。
# 运行时镜像不含 SDK，且以非 root 用户运行（uid 1654）。

ARG SDK_IMAGE=mcr.microsoft.com/dotnet/sdk:10.0
ARG RUNTIME_IMAGE=mcr.microsoft.com/dotnet/aspnet:10.0

# ─────────────── 1. 还原 + 发布 ───────────────
FROM $SDK_IMAGE AS build
WORKDIR /src

# 先只复制项目文件与中央包管理配置：源码没变时这一层能命中缓存，不用重新 restore
COPY Directory.Build.props Directory.Packages.props global.json ./
COPY src/BuildingBlocks/ServiceDiscovery.Abstractions/*.csproj src/BuildingBlocks/ServiceDiscovery.Abstractions/
COPY src/BuildingBlocks/ServiceDiscovery.Nacos/*.csproj src/BuildingBlocks/ServiceDiscovery.Nacos/
COPY src/BuildingBlocks/Observability/*.csproj src/BuildingBlocks/Observability/
COPY src/Gateway/*.csproj src/Gateway/

ARG PROJECT_PATH=src/Gateway/AspNetCoreCloud.Gateway.csproj
RUN dotnet restore "$PROJECT_PATH"

COPY src/ ./src/
RUN dotnet publish "$PROJECT_PATH" -c Release -o /out --no-restore /p:UseAppHost=false

# ─────────────── 2. 运行时 ───────────────
FROM $RUNTIME_IMAGE AS runtime
WORKDIR /app

# curl 只为容器健康检查服务
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build /out ./

# .NET 官方镜像已内置非 root 用户 app（uid 1654），直接复用。
# 不要再 useradd 一个 1654 —— UID 冲突会让构建直接失败（实测踩到）。
USER 1654:1654

ENV ASPNETCORE_URLS=http://0.0.0.0:10000
EXPOSE 10000

HEALTHCHECK --interval=15s --timeout=3s --start-period=25s --retries=5 \
    CMD curl -fsS http://localhost:10000/health/ready || exit 1

ENTRYPOINT ["dotnet", "AspNetCoreCloud.Gateway.dll"]
