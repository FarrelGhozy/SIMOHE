# SIMOHE Server

Backend **SIMOHE** — Bun + TypeScript + Elysia + Drizzle ORM + MySQL 8.

## Prasyarat
- [Bun](https://bun.sh) >= 1.1
- Docker (untuk MySQL lokal) atau MySQL 8 yang sudah ada

## Menjalankan (dev)
```bash
cd server
cp .env.example .env          # sesuaikan bila perlu
docker compose up -d          # MySQL 8.4 di port 3307
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
Semua waktu **UTC**.

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
```
`tests/preload.ts` otomatis membuat & memigrasi database `simohe_test` memakai
kredensial root dari env test.
