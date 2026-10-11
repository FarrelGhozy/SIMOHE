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
      DB[("MySQL 8 (host, tanpa container)")]
      Caddy --> API
      API --> DB
    end
    ESP -->|HTTPS POST /api/iot/ingest| Caddy
    UserApp -->|HTTPS REST| Caddy
```

## Docker Compose (rencana)
```
server/
├── docker-compose.yml                  # server saja (MySQL di host)
├── Dockerfile                          # image Bun untuk Elysia
├── docker-entrypoint.sh                # migrasi → seed → start
├── tools/db/setup.sql                  # setup DB/user di MySQL host
├── Caddyfile                           # reverse proxy + TLS
├── .env                                # rahasia (tidak di-commit)
└── .env.example
```

Isi `docker-compose.yml` (ringkas):
- `server`: build dari `Dockerfile`, memakai **jaringan host**
  (`network_mode: host`) dan memuat `.env`; `DATABASE_URL` menunjuk MySQL lokal
  `127.0.0.1:3306`; migrasi otomatis saat start.
- `caddy`: expose 80/443, reverse proxy ke server, TLS otomatis (rencana).
- **Tidak ada service `mysql`** — MySQL dijalankan langsung di host.

`Dockerfile` (ringkas): base `oven/bun`, install dependensi. Entrypoint
(`docker-entrypoint.sh`) menunggu MySQL siap, menjalankan migrasi, seed device
bila `DEVICE_KEY` diisi, lalu `bun run start`. Service `server` memakai
`restart: always` sehingga otomatis hidup lagi setelah host reboot.

## Environment (`.env.example`)
```
NODE_ENV=production
PORT=3000
DATABASE_URL=mysql://simohe_app:password@127.0.0.1:3306/simohe
APP_TOKEN=change-me-strong-token
APP_CORS_ORIGIN=https://app.example.com
INGEST_RATE_LIMIT_PER_SEC=1
TZ=UTC

RUN_SEED=true
```

## Alur Deploy (ringkas)
1. Siapkan VPS + domain (A record ke IP VPS).
2. Install & jalankan MySQL 8 **di host** VPS; setup DB/user:
   `sudo mysql < server/tools/db/setup.sql`.
3. Clone repo / copy folder `server`.
4. Isi `.env` (jangan commit).
5. `docker compose up -d --build` (hanya container server).
6. Migrasi & seed berjalan otomatis saat container `server` start (seed butuh
   `DEVICE_KEY` di `.env`). Manual: `docker compose exec server bun run db:migrate`.
7. Cek device key di log seed: `docker compose logs server`.
8. Caddy menerbitkan sertifikat TLS otomatis.
9. Uji `GET https://domain/api/health`.
10. Konfigurasi ESP: `server_base_url=https://domain`, `device_key=...`.
11. Build Flutter Web & Android dengan `--dart-define=API_BASE_URL=https://domain`.

## MySQL di Host (bukan container)
MySQL dijadikan **satu** instalasi di host (VPS/komputer server) dan dipakai
aplikasi SIMOHE. Container `server` tidak menyalakan MySQL bawaan.

Container server memakai **jaringan host**, sehingga bisa menjangkau MySQL lokal
di `127.0.0.1:3306` **tanpa** mengubah `bind-address` MySQL. Ini cara paling
sederhana saat server dan MySQL berada di komputer yang sama.

### 1. Siapkan database & user di MySQL host
Jalankan sebagai admin di komputer MySQL:
```bash
sudo mysql < server/tools/db/setup.sql     # atau: mysql -u root -p < ...
```
Skrip membuat DB `simohe` (utf8mb4) + user `simohe_app` + `GRANT`. Password
default `S1mohe!Local` (dev) — **ganti di produksi** dan samakan dengan
`DATABASE_URL`. Setara manualnya:
```sql
CREATE DATABASE IF NOT EXISTS simohe
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'simohe_app'@'%' IDENTIFIED BY 'S1mohe!Local';
GRANT ALL PRIVILEGES ON simohe.* TO 'simohe_app'@'%';
FLUSH PRIVILEGES;
```

### 2. (Hanya bila MySQL di komputer berbeda) buka akses jaringan
Jika MySQL di host/komputer lain (bukan yang menjalankan container), set
`DATABASE_URL` ke IP host MySQL dan buka akses jaringan MySQL:
```ini
# /etc/mysql/mysql.conf.d/mysqld.cnf
[mysqld]
bind-address = 0.0.0.0          # atau IP interface tertentu
default-time-zone = '+00:00'    # semua waktu UTC
max_connections = 200
```
```bash
sudo systemctl restart mysql
sudo ufw allow from <IP-KOMPUTER-APLIKASI> to any port 3306 proto tcp
```
Untuk mode jaringan host (MySQL di komputer yang sama), langkah ini **tidak
diperlukan** (MySQL tetap `127.0.0.1`).

### 3. Arahkan aplikasi ke MySQL
Isi `.env` (lihat juga `tools/db/setup.sql`):
```
DATABASE_URL=mysql://simohe_app:PASSWORD@127.0.0.1:3306/simohe
# MySQL di komputer berbeda:
# DATABASE_URL=mysql://simohe_app:PASSWORD@192.168.1.10:3306/simohe
```
Jalankan server (container server saja):
```bash
docker compose up -d --build
```

### 4. Migrasi & seed
Otomatis saat container start (entrypoint). Manual:
```bash
docker compose exec server bun run db:migrate
docker compose exec server bun run db:seed
```

### Catatan
- User aplikasi cukup `GRANT ALL ON simohe.*` — **jangan** pakai root.
- Jangan ekspos port MySQL ke jaringan publik tanpa firewall.
- Butuh TLS ke MySQL? Tambahkan parameter SSL pada URL (didukung `mysql2`).
- Pantau `max_connections`, CPU/RAM, dan ukuran disk.
- Waktu tetap **UTC**; set `default-time-zone='+00:00'` di host MySQL.

## Database & Backup
- MySQL dijalankan **di host** (bukan container).
- Backup harian: `mysqldump` ke file terkompresi + retensi (mis. 7–30 hari).
- Uji restore berkala.
- Job `retention` membersihkan `telemetry_raw` sesuai `raw_retention_days`.

## Mode Pengembangan Lokal
```bash
# Server (MySQL diasumsikan sudah jalan di host)
cd server && bun install && bun run dev

# Temukan IP LAN (agar HP/ESP bisa akses)
hostname -I    # mis. 192.168.1.10
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
