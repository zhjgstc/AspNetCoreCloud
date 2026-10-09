#!/usr/bin/env bash
# 停止并移除容器，保留 Nacos 数据卷（下次 up 服务实例还在）。
#
#   bash scripts/stop.sh
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

echo "▶ 停止容器（数据卷保留）..."
"${COMPOSE[@]}" "${COMPOSE_ARGS[@]}" down
echo "✓ 已停止。要连数据一起清掉： bash scripts/reset.sh"
