#!/usr/bin/env bash
#
# Live smoke test SIMOHE: jalankan simulator terhadap server yang sedang berjalan,
# lalu cetak ringkasan live/events/commands.
#
# Prasyarat:
#   - MySQL jalan (docker compose up -d) dan `bun run db:migrate` + `db:seed` selesai
#   - server berjalan (`bun run dev` / `bun run start`)
#
# Pemakaian:
#   tools/e2e/smoke.sh [scenario] [duration_sec] [interval_sec]
#   scenario: normal | mature | offline | overheat (default normal)
#
# Env dibaca dari server/.env (DEVICE_KEY, APP_TOKEN, PORT).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

if [[ -f .env ]]; then
  read_env() { grep -E "^${1}=" .env | head -1 | cut -d= -f2- | tr -d '"' | tr -d '\r'; }
  DEVICE_KEY="$(read_env DEVICE_KEY)"
  APP_TOKEN="$(read_env APP_TOKEN)"
  PORT="$(read_env PORT)"
fi

BACKEND_PORT="${PORT:-3000}"
BASE_URL="${BASE_URL:-http://localhost:$BACKEND_PORT}"
SCENARIO="${1:-normal}"
DURATION_SEC="${2:-20}"
INTERVAL_SEC="${3:-2}"

: "${DEVICE_KEY:?DEVICE_KEY tidak ditemukan (isi server/.env)}"
: "${APP_TOKEN:?APP_TOKEN tidak ditemukan (isi server/.env)}"

echo "== health =="
curl -fsS "$BASE_URL/api/health"
echo

echo "== simulator: scenario=$SCENARIO selama ${DURATION_SEC}s (interval ${INTERVAL_SEC}s) =="
timeout "$DURATION_SEC" bun run sim -- \
  --device-key "$DEVICE_KEY" \
  --scenario "$SCENARIO" \
  --interval "$INTERVAL_SEC" \
  --autoconfig --app-token "$APP_TOKEN" || true

echo
echo "== live =="
curl -fsS "$BASE_URL/api/live" -H "Authorization: Bearer $APP_TOKEN"
echo
echo "== events (5 terbaru) =="
curl -fsS "$BASE_URL/api/events?limit=5" -H "Authorization: Bearer $APP_TOKEN"
echo
echo "== commands (5 terbaru) =="
curl -fsS "$BASE_URL/api/commands?limit=5" -H "Authorization: Bearer $APP_TOKEN"
echo
