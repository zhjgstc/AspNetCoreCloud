#!/usr/bin/env bash
# 清数据重来：停止容器 + 删除数据卷（Nacos 里的实例与配置全部丢失）+ 可选删镜像。
#
#   bash scripts/reset.sh
#   bash scripts/reset.sh --images   # 连本地构建的业务镜像一起删
#
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMPOSE_FILE="$ROOT_DIR/deploy/compose/docker-compose.yml"
ENV_FILE="$ROOT_DIR/deploy/compose/.env"

if docker compose version >/dev/null 2>&1; then
  COMPOSE=(docker compose)
else
  COMPOSE=(docker-compose)
fi

COMPOSE_ARGS=(-f "$COMPOSE_FILE")
[ -f "$ENV_FILE" ] && COMPOSE_ARGS+=(--env-file "$ENV_FILE")

echo "⚠ 这会删除全部容器与 Nacos 数据卷（实例、配置都会丢）。"
read -r -p "确认请输入 yes: " ANSWER
[ "$ANSWER" = "yes" ] || { echo "已取消"; exit 0; }

"${COMPOSE[@]}" "${COMPOSE_ARGS[@]}" down -v --remove-orphans
echo "✓ 容器与数据卷已清除"

if [ "${1:-}" = "--images" ]; then
  for s in gateway auth order product; do
    docker rmi "aspnetcorecloud/$s:latest" >/dev/null 2>&1 && echo "  已删镜像 aspnetcorecloud/$s:latest"
  done
fi
