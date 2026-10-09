#!/usr/bin/env bash
# 一条命令起全套：构建镜像 → 启动容器 → 等健康 → 打印访问地址。
#
#   bash scripts/start.sh          # 构建并启动
#   bash scripts/start.sh --pull   # 不构建，直接从 registry 拉镜像（CI 发布后用这个）
#
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMPOSE_FILE="$ROOT_DIR/deploy/compose/docker-compose.yml"
ENV_FILE="$ROOT_DIR/deploy/compose/.env"
ENV_EXAMPLE="$ROOT_DIR/deploy/compose/.env.example"

# 兼容 docker compose v2 与老的 docker-compose
if docker compose version >/dev/null 2>&1; then
  COMPOSE=(docker compose)
elif command -v docker-compose >/dev/null 2>&1; then
  COMPOSE=(docker-compose)
else
  echo "✗ 没找到 docker compose。请安装 Docker Desktop 或 Docker Engine + Compose 插件。"
  exit 1
fi

if ! docker info >/dev/null 2>&1; then
  echo "✗ Docker 守护进程没在跑。请先启动 Docker。"
  exit 1
fi

if [ ! -f "$ENV_FILE" ] && [ -f "$ENV_EXAMPLE" ]; then
  cp "$ENV_EXAMPLE" "$ENV_FILE"
  echo "· 已按默认值生成 $ENV_FILE（需要改端口/版本就编辑它）"
fi

COMPOSE_ARGS=(-f "$COMPOSE_FILE")
[ -f "$ENV_FILE" ] && COMPOSE_ARGS+=(--env-file "$ENV_FILE")

echo "▶ 启动 AspNetCoreCloud（首次会构建 4 个 .NET 镜像，需要几分钟）..."
if [ "${1:-}" = "--pull" ]; then
  "${COMPOSE[@]}" "${COMPOSE_ARGS[@]}" pull
  "${COMPOSE[@]}" "${COMPOSE_ARGS[@]}" up -d
else
  "${COMPOSE[@]}" "${COMPOSE_ARGS[@]}" up -d --build
fi

echo
echo "▶ 等待服务健康检查通过（Nacos 冷启动较慢，最多等 3 分钟）..."
DEADLINE=$(( $(date +%s) + 180 ))
while [ "$(date +%s)" -lt "$DEADLINE" ]; do
  # 统计尚未 healthy 且带 healthcheck 的容器数量
  PENDING="$("${COMPOSE[@]}" "${COMPOSE_ARGS[@]}" ps --format json 2>/dev/null \
    | grep -o '"Health":"[a-z]*"' | grep -v '"Health":"healthy"' | wc -l | tr -d ' ' || echo 0)"
  TOTAL="$("${COMPOSE[@]}" "${COMPOSE_ARGS[@]}" ps --format json 2>/dev/null \
    | grep -o '"Health":"[a-z]*"' | wc -l | tr -d ' ' || echo 0)"
  if [ "${TOTAL:-0}" -gt 0 ] && [ "${PENDING:-0}" -eq 0 ]; then
    echo "✓ 全部容器 healthy"
    break
  fi
  sleep 5
done

echo
bash "$ROOT_DIR/scripts/status.sh"
