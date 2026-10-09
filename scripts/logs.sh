#!/usr/bin/env bash
# 看日志。不带参数=全部服务；带服务名=只看那个。
#
#   bash scripts/logs.sh
#   bash scripts/logs.sh gateway
#   bash scripts/logs.sh product --tail 100
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

SERVICE="${1:-}"
if [ -n "$SERVICE" ]; then
  shift
  "${COMPOSE[@]}" "${COMPOSE_ARGS[@]}" logs -f "$@" "$SERVICE"
else
  "${COMPOSE[@]}" "${COMPOSE_ARGS[@]}" logs -f "$@"
fi
