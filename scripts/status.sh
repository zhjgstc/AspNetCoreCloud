#!/usr/bin/env bash
# 查看当前服务与服务状态：容器状态 + 健康端点 + 网关实际在用的后端实例。
#
#   bash scripts/status.sh
#
set -uo pipefail

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

# 从 .env 读端口，读不到就用默认值
port_of() { # $1=环境变量名 $2=默认端口
  local v=""
  [ -f "$ENV_FILE" ] && v="$(grep -E "^${1}=" "$ENV_FILE" | tail -1 | cut -d= -f2- || true)"
  echo "${v:-$2}"
}

GW=$(port_of GATEWAY_PORT 10000)
NACOS=$(port_of NACOS_PORT 18848)
DASH=$(port_of DASHBOARD_PORT 18888)

echo "════════ 容器状态 ════════"
"${COMPOSE[@]}" "${COMPOSE_ARGS[@]}" ps 2>/dev/null || echo "(docker 不可用或没有运行中的容器)"

echo
echo "════════ 网关 ════════"
code=$(curl -s -o /tmp/_cc_health -w '%{http_code}' -m 4 "http://localhost:$GW/health" 2>/dev/null || echo "000")
printf "  gateway  :%-6s HTTP %s  %s\n" "$GW" "$code" "$(head -c 60 /tmp/_cc_health 2>/dev/null | tr -d '\n')"
rm -f /tmp/_cc_health
echo "  （业务服务默认不映射宿主端口，健康状态看上面容器表的 healthy；"
echo "    要直连调试：up 时加 -f deploy/compose/docker-compose.debug.yml）"

echo
echo "════════ 网关后端实例（来自 Nacos）════════"
if [ "$(curl -s -o /dev/null -w '%{http_code}' -m 4 "http://localhost:$GW/gateway/routes" || echo 000)" = "200" ]; then
  curl -s -m 6 "http://localhost:$GW/gateway/routes" \
    | tr ',' '\n' | grep -E '"(clusterId|address|routeId)"' \
    | sed 's/^/  /' | head -30
else
  echo "  (网关未就绪或没在跑)"
fi

echo
echo "════════ 控制台 ════════"
echo "  Nacos 控制台        http://localhost:$NACOS/nacos"
echo "  Aspire Dashboard    http://localhost:$DASH"
echo "  网关诊断            http://localhost:$GW/gateway"
echo
echo "  取 token： curl -s http://localhost:$GW/gateway/token"
echo "  调一次跨服务链路： curl -i -H \"Authorization: Bearer \$(curl -s http://localhost:$GW/gateway/token | grep -o '\"accessToken\":\"[^\"]*' | cut -d'\"' -f4)\" http://localhost:$GW/api/order/lb"
