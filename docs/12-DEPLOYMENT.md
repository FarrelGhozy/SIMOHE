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
├── docker-compose.yml                  # mysql + server (all-in-one)
├── docker-compose.central-db.yml       # override: pakai MySQL terpusat
├── Dockerfile                          # image Bun untuk Elysia
├── docker-entrypoint.sh                # migrasi → seed → start
├── tools/db/central-setup.sql          # setup DB/user di MySQL terpusat
├── Caddyfile                           # reverse proxy + TLS
├── .env                                # rahasia (tidak di-commit)
└── .env.example
```

Isi `docker-compose.yml` (ringkas):
- `mysql`: image `mysql:8.4`, volume persisten, user non-root, DB `simohe`.
- `server`: build dari `Dockerfile`, `depends_on: mysql` (sehat), memuat
  `.env`; migrasi otomatis saat start.
- `caddy`: expose 80/443, reverse proxy ke `server`, TLS otomatis.

`Dockerfile` (ringkas): base `oven/bun`, install dependensi. Entrypoint
(`docker-entrypoint.sh`) menunggu MySQL sehat, menjalankan migrasi, seed device
bila `DEVICE_KEY` diisi, lalu `bun run start`. Kedua service
(`mysql`, `server`) memakai `restart: always` sehingga otomatis hidup lagi
setelah host reboot.

## Environment (`.env.example`)
```
NODE_ENV=production
PORT=3000
DATABASE_URL=mysql://simohe_user:password@mysql:3306/simohe
APP_TOKEN=change-me-strong-token
APP_CORS_ORIGIN=https://app.example.com
INGEST_RATE_LIMIT_PER_SEC=1
TZ=UTC

# Docker (semua pengaturan container diatur dari sini)
DOCKER_SERVER_HOST_PORT=3001          # port host container server
DOCKER_MYSQL_HOST_PORT=3307           # port host container MySQL
DOCKER_DATABASE_URL=mysql://user:password@mysql:3306/simohe
RUN_SEED=true
```

## Alur Deploy (ringkas)
1. Siapkan VPS + domain (A record ke IP VPS).
2. Clone repo / copy folder `server`.
3. Isi `.env` (jangan commit).
4. `docker compose up -d --build`.
5. Migrasi & seed berjalan otomatis saat container `server` start (seed butuh
   `DEVICE_KEY` di `.env`). Manual: `docker compose exec server bun run db:migrate`.
6. Cek device key di log seed: `docker compose logs server`.
7. Caddy menerbitkan sertifikat TLS otomatis.
8. Uji `GET https://domain/api/health`.
9. Konfigurasi ESP: `server_base_url=https://domain`, `device_key=...`.
10. Build Flutter Web & Android dengan `--dart-define=API_BASE_URL=https://domain`.

## Database Terpusat (MySQL bersama aplikasi lain)
Skenario: MySQL dijadikan **satu** di komputer server dan dipakai bersama
aplikasi lain. Container `server` tidak menyalakan MySQL bawaan, melainkan
terhubung ke MySQL terpusat.

Dua sub-kasus:
- MySQL di komputer yang **sama** dengan container → host `host.docker.internal`
  (sudah dipetakan via `extra_hosts` di file override).
- MySQL di komputer **berbeda** → pakai IP/DNS server MySQL.

### 1. Siapkan database & user di server MySQL
Jalankan sebagai root di komputer MySQL:
```bash
mysql -u root -p < server/tools/db/central-setup.sql
```
Skrip membuat DB `simohe` (utf8mb4) + user `simohe_app` + `GRANT`. **Ganti
password** di dalam file dulu. Setara manualnya:
```sql
CREATE DATABASE IF NOT EXISTS simohe
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'simohe_app'@'%' IDENTIFIED BY 'GANTI-PASSWORD-KUAT';
GRANT ALL PRIVILEGES ON simohe.* TO 'simohe_app'@'%';
FLUSH PRIVILEGES;
```

### 2. Konfigurasi MySQL agar dapat diakses
Di `/etc/mysql/mysql.conf.d/mysqld.cnf` (server MySQL):
```ini
[mysqld]
bind-address = 0.0.0.0          # atau IP interface tertentu
default-time-zone = '+00:00'   # semua waktu UTC
max_connections = 200          # sesuaikan dengan jumlah aplikasi
```
```bash
sudo systemctl restart mysql
```
Buka firewall **hanya** untuk host aplikasi:
```bash
sudo ufw allow from <IP-KOMPUTER-APLIKASI> to any port 3306 proto tcp
```

### 3. Arahkan aplikasi ke DB terpusat
Isi `.env` (lihat juga `tools/db/central-setup.sql`):
```
CENTRAL_DATABASE_URL=mysql://simohe_app:PASSWORD@192.168.1.10:3306/simohe
```
Jalankan server dengan override `central-db` (MySQL bawaan **tidak** ikut):
```bash
# build + jalankan server saja
docker compose -f docker-compose.yml -f docker-compose.central-db.yml up -d --build server
```
Override ini: menonaktifkan service `mysql` (profil `local-db`), menghapus
`depends_on`, mengganti `DATABASE_URL` ke `CENTRAL_DATABASE_URL`, dan menambah
`host.docker.internal`. Jika MySQL di komputer yang sama dengan container,
cukup set:
```
CENTRAL_DATABASE_URL=mysql://simohe_app:PASSWORD@host.docker.internal:3306/simohe
```

### 4. Migrasi & seed
Otomatis saat container start (entrypoint). Manual:
```bash
docker compose -f docker-compose.yml -f docker-compose.central-db.yml exec server bun run db:migrate
docker compose -f docker-compose.yml -f docker-compose.central-db.yml exec server bun run db:seed
```

### Catatan
- User aplikasi cukup `GRANT ALL ON simohe.*` — **jangan** pakai root.
- Jangan ekspos port MySQL ke jaringan publik tanpa firewall.
- Butuh TLS ke MySQL? Tambahkan parameter SSL pada URL (didukung `mysql2`).
- Saat berbagi MySQL dengan aplikasi lain, pantau `max_connections`,
  CPU/RAM, dan ukuran disk.
- Waktu tetap **UTC**; set `default-time-zone='+00:00'` di server MySQL.

## Database & Backup
- Dua mode: MySQL **bawaan** (volume `simohe_mysql_data`) atau **terpusat**
  (dikelola server MySQL bersama aplikasi lain).
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
