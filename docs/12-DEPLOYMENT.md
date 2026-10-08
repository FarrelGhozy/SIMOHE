# 12 — Deployment

## Target
- Server Bun + Elysia + MySQL berjalan di VPS (atau server sendiri) via Docker.
- Reverse proxy dengan TLS otomatis (Caddy).
- Aplikasi Flutter: Android (APK), Web (static hosting / disajikan server).
- Perangkat ESP8266 menunjuk ke domain/IP server.

## Topologi

```mermaid
flowchart TB
    subgraph Internet
      ESP["ESP8266 (lapangan)"]
      UserApp["Aplikasi Web / Android"]
    end
    subgraph VPS["VPS / Server"]
      Caddy["Caddy / Nginx (TLS, reverse proxy)"]
      API["Container: Bun + Elysia"]
      DB[("Container: MySQL 8 (volume)")]
      Caddy --> API
      API --> DB
    end
    ESP -->|HTTPS POST /api/iot/ingest| Caddy
    UserApp -->|HTTPS REST| Caddy
```

## Docker Compose (rencana)
```
server/
├── docker-compose.yml
├── Dockerfile                # image Bun untuk Elysia
├── Caddyfile                 # reverse proxy + TLS
├── .env                      # rahasia (tidak di-commit)
└── .env.example
```

Isi `docker-compose.yml` (ringkas):
- `mysql`: image `mysql:8`, volume persisten, user non-root, DB `simohe`.
- `api`: build dari `Dockerfile`, `depends_on: mysql`, expose port internal,
  memuat `.env`.
- `caddy`: expose 80/443, reverse proxy ke `api`, TLS otomatis.

`Dockerfile` (ringkas): base `oven/bun`, install dependensi, jalankan migrasi
saat start (atau job terpisah), lalu `bun run start`.

## Environment (`.env.example`)
```
NODE_ENV=production
PORT=3000
DATABASE_URL=mysql://simohe_user:password@mysql:3306/simohe
APP_TOKEN=change-me-strong-token
APP_CORS_ORIGIN=https://app.example.com
INGEST_RATE_LIMIT_PER_SEC=1
TZ=UTC
```

## Alur Deploy (ringkas)
1. Siapkan VPS + domain (A record ke IP VPS).
2. Clone repo / copy folder `server`.
3. Isi `.env` (jangan commit).
4. `docker compose up -d --build`.
5. Jalankan migrasi: `docker compose exec api bun run db:migrate`.
6. Seed device + `device_key` + `settings`.
7. Caddy menerbitkan sertifikat TLS otomatis.
8. Uji `GET https://domain/api/health`.
9. Konfigurasi ESP: `server_base_url=https://domain`, `device_key=...`.
10. Build Flutter Web & Android dengan `--dart-define=API_BASE_URL=https://domain`.

## Database & Backup
- Volume Docker untuk data MySQL.
- Backup harian: `mysqldump` ke file terkompresi + retensi (mis. 7–30 hari).
- Uji restore berkala.
- Job `retention` membersihkan `telemetry_raw` sesuai `raw_retention_days`.

## Mode Pengembangan Lokal
```bash
# Server
cd server && bun install && bun run dev

# Temukan IP LAN (agar HP/ESP bisa akses)
hostname -I    # mis. 192.168.1.10

# Jalankan MySQL lokal (docker)
docker compose up -d mysql
```

- ESP diuji dengan `server_base_url=http://192.168.1.10:3000`.
- Flutter: `flutter run --dart-define=API_BASE_URL=http://192.168.1.10:3000`.

## Platform Tambahan (nanti)
- iOS/macOS: butuh macOS + Xcode; tambahkan dengan
  `flutter create --platforms=ios,macos .`.
- Windows/Linux desktop: `flutter create --platforms=windows,linux .`.
- Tanpa perubahan arsitektur; hanya target build.

## Operasional
- Health check `/api/health` dipantau (uptime).
- Log terpusat (docker logs / file).
- Alert sederhana bila container mati (opsional: tool monitoring).

## CI/CD (opsional, fase lanjut)
- Lint + test saat push (GitHub Actions).
- Build image & deploy otomatis ke VPS.
- Build APK/Web artefak.
