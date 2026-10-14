#!/bin/sh
set -e

echo "[entrypoint] menunggu MySQL siap & menerapkan migrasi..."
attempt=0
until bun run db:migrate; do
  attempt=$((attempt + 1))
  if [ "$attempt" -ge 15 ]; then
    echo "[entrypoint] migrasi gagal setelah $attempt percobaan" >&2
    exit 1
  fi
  echo "[entrypoint] MySQL belum siap, coba lagi ($attempt/15)..."
  sleep 3
done

if [ -n "${DEVICE_KEY:-}" ] && [ "${RUN_SEED:-true}" != "false" ]; then
  echo "[entrypoint] menjalankan seed device..."
  bun run db:seed || echo "[entrypoint] seed gagal/dilewati" >&2
fi

echo "[entrypoint] memulai server..."
exec bun run start
