#!/usr/bin/env bash
# sim-curl.sh — Simulator ingest sementara pengganti server/tools/simulator.ts.
# Mengirim telemetry ke Edge Function iot-ingest + meng-ack commands.
# Butuh: SUPABASE_URL, SUPABASE_PUBLISHABLE_KEY (fallback SUPABASE_ANON_KEY), DEVICE_KEY di environment.
#
#   SUPABASE_URL=https://<ref>.supabase.co SUPABASE_PUBLISHABLE_KEY=<publishable> \
#     DEVICE_KEY=<key> ./sim-curl.sh normal [jumlah] [jeda_detik]
# Skenario: normal | mature | overheat | offline
set -euo pipefail

: "${SUPABASE_URL:?isi SUPABASE_URL}"
# Terima nama baru maupun lama.
SUPABASE_PUBLISHABLE_KEY="${SUPABASE_PUBLISHABLE_KEY:-${SUPABASE_ANON_KEY:-}}"
: "${SUPABASE_PUBLISHABLE_KEY:?isi SUPABASE_PUBLISHABLE_KEY (atau SUPABASE_ANON_KEY)}"
: "${DEVICE_KEY:?isi DEVICE_KEY}"

SCENARIO="${1:-normal}"
COUNT="${2:-20}"
SLEEP_SEC="${3:-2}"
BASE="$SUPABASE_URL/functions/v1/iot-ingest"
SEQ=1
PENDING_ACKS=""

ingest() {
  local temp_c="$1" nh3="$2" heater="$3" extra_events="$4"
  local acks_json="[]"
  if [ -n "$PENDING_ACKS" ]; then
    acks_json=$(printf '%s' "$PENDING_ACKS" | tr ' ' '\n' | grep -v '^$' | sed 's/^\(.*\)$/{"id":"\1","ok":true}/' | paste -sd, - | sed 's/^/[/;s/$/]/')
    PENDING_ACKS=""
  fi
  local body
  body=$(cat <<EOF
{"seq":$SEQ,"firmware":"0.1.0-sim","ts":"$(date -u +%Y-%m-%dT%H:%M:%SZ)","telemetry":{"temp_c":$temp_c,"nh3_ppm":$nh3,"temp_ok":true,"heater":$heater,"valve":false,"mode":"AUTO","mature":false,"uptime":1000},"events":[$extra_events],"acks":$acks_json}
EOF
)
  echo "--- ingest #$SEQ temp=$temp_c nh3=$nh3 heater=$heater"
  local resp
  resp=$(curl -s -X POST "$BASE" \
    -H "Content-Type: application/json" \
    -H "apikey: $SUPABASE_PUBLISHABLE_KEY" \
    -H "Authorization: Bearer $SUPABASE_PUBLISHABLE_KEY" \
    -H "X-Device-Key: $DEVICE_KEY" \
    -d "$body")
  echo "$resp" | head -c 600; echo
  # Kumpulkan command id untuk di-ack pada ingest berikutnya.
  local ids
  ids=$(echo "$resp" | grep -o '"id":"[^"]*"' | head -5 | cut -d'"' -f4 || true)
  if [ -n "$ids" ]; then
    PENDING_ACKS="$PENDING_ACKS $ids"
    echo ">>> akan ack:$PENDING_ACKS"
  fi
  SEQ=$((SEQ + 1))
}

case "$SCENARIO" in
normal)
  for _ in $(seq 1 "$COUNT"); do ingest 27.5 12.1 true ""; sleep "$SLEEP_SEC"; done ;;
mature)
  for _ in $(seq 1 "$COUNT"); do ingest 34.0 26.5 false ""; sleep "$SLEEP_SEC"; done ;;
overheat)
  for _ in $(seq 1 "$COUNT"); do ingest 46.0 18.0 false ""; sleep "$SLEEP_SEC"; done ;;
offline)
  echo "diam $COUNT detik (tanpa ingest) untuk memicu device_offline..."; sleep "$COUNT"
  ingest 33.0 15.0 false "" ;;
safety)
  ingest 33.0 15.0 false '{"code":"SAFETY_CUTOFF","detail":"heater_max_on"}' ;;
*) echo "skenario: normal|mature|overheat|offline|safety"; exit 1 ;;
esac
