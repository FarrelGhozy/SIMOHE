# SIMOHE Server

Backend **SIMOHE** — Bun + TypeScript + Elysia + Drizzle ORM + MySQL 8.

## Prasyarat
- [Bun](https://bun.sh) >= 1.1
- Docker (untuk MySQL lokal) atau MySQL 8 yang sudah ada

## Menjalankan (Docker — server + database sekaligus)
```bash
cd server
cp .env.example .env          # sesuaikan (APP_TOKEN, DEVICE_KEY, dll)

# Build + jalankan MySQL & server sebagai daemon
docker compose up --build -d
```
`docker compose up --build -d` menyalakan **MySQL + server** sekaligus. Kedua
container memakai `restart: always`, jadi otomatis hidup lagi setelah komputer
host reboot (pastikan service Docker aktif saat boot). Container server
menunggu MySQL sehat, menerapkan migrasi, lalu menjalankan server. Seed device
otomatis dijalankan bila `DEVICE_KEY` diisi di `.env` (idempoten).

Semua pengaturan Docker diatur lewat `.env` (bukan hardcode di compose):

| Variabel | Default | Fungsi |
|---|---|---|
| `DOCKER_SERVER_HOST_PORT` | `3001` | Port host untuk container server |
| `DOCKER_MYSQL_HOST_PORT` | `3307` | Port host untuk container MySQL |
| `DOCKER_DATABASE_URL` | `mysql://simohe:simohe@mysql:3306/simohe` | URL DB dari dalam jaringan Docker |
| `PORT` | `3000` | Port server di dalam container |
| `RUN_SEED` | `true` | Seed otomatis saat start (bila `DEVICE_KEY` diisi) |

`DOCKER_SERVER_HOST_PORT` sengaja dibedakan dari `PORT` agar Docker tidak
bentrok dengan dev lokal (`bun run dev`) di port 3000.

Menyalakan/mengelola per container:
```bash
docker compose up -d mysql          # hanya database
docker compose up -d server         # hanya server (mysql ikut bila belum jalan)
docker compose logs -f server       # lihat log server (termasuk device key seed)
docker compose exec server bun run db:seed   # seed manual (cetak device key)
docker compose restart server       # restart server saja
docker compose down                 # hentikan semua (data MySQL tetap di volume)
```
Karena default host port server `3001`, akses server Docker di
http://localhost:3001 (bukan 3000).

## Menjalankan dengan Database Terpusat (MySQL bersama aplikasi lain)
Bila MySQL tidak dijalankan sebagai container bawaan, melainkan di komputer
server (bersama aplikasi lain), pakai override `docker-compose.central-db.yml`.
Service `mysql` dinonaktifkan dan `server` terhubung ke `CENTRAL_DATABASE_URL`.

1. Di komputer MySQL, siapkan DB + user (ganti password di file dulu):
   ```bash
   mysql -u root -p < tools/db/central-setup.sql
   ```
2. Isi `.env`:
   ```
   # MySQL di komputer lain:
   CENTRAL_DATABASE_URL=mysql://simohe_app:PASSWORD@192.168.1.10:3306/simohe
   # atau MySQL di komputer yang sama dengan container:
   CENTRAL_DATABASE_URL=mysql://simohe_app:PASSWORD@host.docker.internal:3306/simohe
   ```
3. Jalankan server saja (tanpa MySQL bawaan):
   ```bash
   docker compose -f docker-compose.yml -f docker-compose.central-db.yml up -d --build server
   ```
Migrasi & seed tetap berjalan otomatis saat start. Detail lengkap (konfigurasi
`bind-address`, timezone UTC, firewall, backup) ada di
`../docs/12-DEPLOYMENT.md` bagian **Database Terpusat**.

## Menjalankan (dev tanpa Docker untuk server)
```bash
cd server
cp .env.example .env          # sesuaikan bila perlu
docker compose up -d mysql    # MySQL 8.4 di port 3307
bun install
bun run db:migrate            # terapkan migrasi
bun run db:seed               # device + settings + batch awal
bun run dev                   # server di http://localhost:3000
```
`db:seed` mencetak **device key plaintext sekali** — simpan untuk ESP/simulator.
Di DB hanya tersimpan hash SHA-256 (`device_key CHAR(64)`).

Dokumentasi API interaktif (dev): http://localhost:3000/api/docs

## Script
| Script | Fungsi |
|---|---|
| `bun run dev` | Jalankan server dengan watch |
| `bun run start` | Jalankan server produksi |
| `bun test` | Unit + integration test |
| `bun run test:e2e` | Matriks e2e T1–T10 via simulator (butuh MySQL test) |
| `bun run lint` | Biome check |
| `bun run lint:fix` | Biome check + auto-fix |
| `bun run typecheck` | `tsc --noEmit` (`strict`) |
| `bun run db:generate` | Generate migrasi dari schema |
| `bun run db:migrate` | Terapkan migrasi |
| `bun run db:seed` | Seed data awal |
| `bun run key:hash <key>` | Hitung SHA-256 device key manual |
| `bun run sim -- --device-key <key>` | Jalankan simulator perangkat |

## Environment
Lihat `.env.example`. Kunci: `DATABASE_URL`, `APP_TOKEN`, `APP_CORS_ORIGIN`,
`DEVICE_KEY` (seed), `RATE_LIMIT_INGEST_PER_SEC`, `RATE_LIMIT_APP_PER_SEC`.
Pengaturan Docker: `DOCKER_SERVER_HOST_PORT`, `DOCKER_MYSQL_HOST_PORT`,
`DOCKER_DATABASE_URL`, `RUN_SEED`. Semua waktu **UTC**.

## Struktur
```
src/
├── index.ts        # bootstrap listen
├── app.ts          # rakitan plugin: error, CORS, rate limit, modul, docs
├── env.ts          # validasi environment
├── logger.ts       # pino
├── db/
│   ├── client.ts   # pool mysql2 + drizzle
│   ├── schema/     # definisi tabel (1 file per tabel) + index.ts
│   ├── seed.ts
│   └── hash-key.ts
├── lib/            # util lintas fitur (hash, waktu, device aktif, AppError)
├── middlewares/    # error, auth-device, auth-app, rate-limit
├── services/       # logika bisnis murni (maturity, thermal, command, event)
└── modules/        # 1 folder per fitur endpoint
    ├── health/ iot/ live/ readings/ summary/
    ├── settings/ commands/ events/ batches/ device/
    └── ...
```
Setiap modul memisah tanggung jawab: `index.ts` (route + skema),
`service.ts` (query/akses data), `schema.ts` (validasi), dan berkas pendukung
lain bila perlu (`bucket.ts`, `response.ts`, `ingest.ts`).

## Konvensi Struktur Kode (PENTING)
**Jangan menumpuk satu berkas besar.** Pecah kode per tanggung jawab:
- 1 fitur/domain = 1 folder di `modules/` atau `services/`.
- `index.ts` hanya merakit route + validasi; logika pindah ke `service.ts`.
- Skema validasi ke `schema.ts`; mapper respons ke `response.ts`.
- Bila sebuah berkas sudah membesar (mis. > ~150 baris atau menangani beberapa
  tugas), **pecah menjadi sub-berkas per tugas** (contoh: `maturity` dipecah ke
  `evaluate.ts`/`progress.ts`; endpoint `iot` dipecah ke `ingest.ts`,
  `response.ts`, `schema.ts`).
- Utilitas yang dipakai lintas fitur ke `lib/`; jangan duplikasi.
- Tes mengikuti struktur: `tests/unit/` dan `tests/integration/`.

## Arsitektur Singkat
- Perangkat mengirim `POST /api/iot/ingest` (header `X-Device-Key`).
- Server memperbarui `latest_state`, mengevaluasi bisnis (`services/`),
  membuat event, menyimpan `telemetry_raw` bila `raw_retention_days > 0`,
  lalu membalas `config` + daftar `commands` pending.
- Aplikasi memakai `Authorization: Bearer <APP_TOKEN>`.

Desain lengkap ada di `../docs/` (mulai `docs/06-BACKEND-API.md`).

## Job Background
Berjalan di proses server yang sama saat `JOBS_ENABLED=true` (default).
Penjadwal di `src/lib/scheduler.ts` (berbasis `setInterval`, non-overlap).

| Job | Interval | Tugas |
|---|---|---|
| `sampling` | cek 30s | Salin `latest_state` → `sensor_readings` bila jatuh tempo (`history_interval_min`) |
| `offline-detector` | 30s | Tandai offline + event bila lewat 3× `ingest_interval_sec` |
| `command-expiry` | 30s | `pending` lewat TTL → `expired` |
| `retention` | 24 jam | Hapus `telemetry_raw` lebih tua dari `raw_retention_days` |

Set `JOBS_ENABLED=false` untuk mematikan (mis. saat menjalankan test manual).

## Simulator Perangkat
Meniru Mega + ESP8266 tanpa hardware (`tools/simulator/`). Skenario:
`normal`, `mature`, `offline`, `overheat`. Simulator menerapkan `commands`
dari respons ingest dan mengirim `acks` pada ingest berikutnya.

```bash
# Device key dari output `bun run db:seed` atau DEVICE_KEY di .env
bun run sim -- --device-key <KEY>

# Uji cepat histori & matang: set history_interval_min=1, mature_hold_min=1
bun run sim -- --device-key <KEY> --autoconfig --app-token <APP_TOKEN>

# Skenario lain / kirim sekali
bun run sim -- --device-key <KEY> --scenario offline
bun run sim -- --device-key <KEY> --once
```
Lihat opsi lengkap: `bun run sim -- --help` (tampil saat `--device-key` kosong).
Amati hasilnya di `GET /api/live`, `GET /api/readings`, dan `GET /api/events`.

## Testing
```bash
bun test                       # semua (butuh MySQL test di port 3307)
bun test tests/unit            # unit service (tanpa DB)
bun test tests/integration     # endpoint (pakai DB simohe_test)
bun run test:e2e               # matriks bisnis T1-T10 via simulator
```
`tests/preload.ts` otomatis membuat & memigrasi database `simohe_test` memakai
kredensial root dari env test.

## Live Smoke (server + simulator)
Pastikan server berjalan, lalu:
```bash
tools/e2e/smoke.sh normal 20 2      # scenario, durasi detik, interval detik
```
Skrip membaca `DEVICE_KEY`/`APP_TOKEN`/`PORT` dari `server/.env`, menjalankan
simulator sebentar, lalu mencetak `live`, `events`, dan `commands`.
