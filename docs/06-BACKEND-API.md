# 06 — Backend API

> **Migrasi 2026-10-14 (Fase 8)**: Bun+Elysia+MySQL diganti Supabase.
> Implementasi lama diarsipkan di `reference/archive/server-bun-2026-10-14/`.
> Bentuk respons di bawah dipertahankan agar aplikasi & firmware kompatibel.

## Stack
- Platform: **Supabase** (Free tier)
- Bahasa: **TypeScript (Deno)** untuk Edge Functions
- Database: **Postgres + RLS** (skema di `supabase/migrations/`)
- Realtime: channel Postgres untuk live/events/commands (fallback polling)
- Cron: pg_cron tiap menit → `jobs-tick`

## Struktur Backend
```
supabase/
├── migrations/0001_init.sql      # 8 tabel + RLS
├── migrations/0002_events_read.sql # UPDATE is_read + trigger guard
├── seed.sql
├── cron.sql                      # jobs-tick tiap menit
├── config.toml                   # verify_jwt=false (auth custom)
└── functions/
    ├── _shared/                  # errors, db, auth, logic, validation
    ├── iot-ingest/               # ingest perangkat
    ├── app-command/              # perintah + cancel
    ├── app-settings/             # tulis pengaturan
    ├── app-batch/                # siklus
    └── jobs-tick/                # sampling/offline/expiry/retention
```

## Autentikasi
- **Perangkat**: header `X-Device-Key: <device_key>` (hash SHA-256 di DB) +
  header Supabase `apikey`/`Authorization: Bearer <publishable>`.
- **Aplikasi (single user, tanpa login)**: publishable key + RLS read-only;
  tulis hanya via Edge Functions. Opsional: `APP_WRITE_KEY` (header
  `X-App-Key`) bila secret diset.
- `service_role` hanya di Edge Functions Secrets, tidak pernah di repo.

## Format Error Seragam
```json
{ "error": { "code": "VALIDATION_ERROR", "message": "temp_c wajib angka" } }
```

## Endpoint

### IoT (Edge Function)
| Method | Path | Auth | Deskripsi |
|---|---|---|---|
| POST | `/functions/v1/iot-ingest` | Device | Kirim telemetry, terima config+commands |

### Aplikasi — baca langsung PostgREST (RLS anon SELECT)
| Tabel | Dipakai untuk |
|---|---|
| `devices` + `latest_state` + `settings` | Live (dulu `GET /api/live`) |
| `sensor_readings` / `telemetry_raw` | Histori (dulu `GET /api/readings`; bucket `1h` agregasi klien) |
| `sensor_readings` (agregasi klien) | Ringkasan (dulu `GET /api/summary`) |
| `events` (+ count unread) | Notifikasi (dulu `GET /api/events`) |
| `commands` | Riwayat perintah (dulu `GET /api/commands`) |
| `devices` | Info device (dulu `GET /api/device`) |
| `batches` | Daftar siklus (dulu `GET /api/batches`) |

### Aplikasi — tulis via Edge Functions
| Invoke | Body | Deskripsi |
|---|---|---|
| `app-command` | `{action, args?}` | Antre perintah → `201 {id, action, status, expires_at}` |
| `app-command` | `{op:'cancel', id}` | Batalkan pending → `200 {id, status}` (409 bila tak pending) |
| `app-settings` | patch parsial | Ubah pengaturan → `200` settings penuh |
| `app-batch` | `{op:'create', label?}` / `{op:'harvest', id}` | Siklus baru / panen |

### Tandai dibaca (langsung, dibatasi trigger)
| Operasi | Deskripsi |
|---|---|
| `UPDATE events SET is_read=true WHERE id=..` | Tandai dibaca (trigger menolak ubahan kolom lain) |
| `UPDATE events SET is_read=true WHERE device_id=..` | Tandai semua dibaca |

## Kontrak Penting (bentuk dipertahankan)

### Live (digabung klien dari 3 tabel) — dulu `GET /api/live`
```json
{
  "device": {"id": "1", "name": "Reaktor Pupuk 1", "online": true,
             "last_seen_at": "...", "firmware": "0.1.0"},
  "state": {"temp_c": 31.2, "nh3_ppm": 18.42, "temp_ok": true,
            "heater_on": true, "valve_open": false, "mode": "AUTO",
            "status": "heating", "updated_at": "..."},
  "maturity": {"mature": false, "progress": 0.35, "threshold_ppm": 25.0,
               "hold_minutes": 30, "streak_sec": 630}
}
```

### `app-command` create (request)
```json
{ "action": "valve_open", "args": {} }
```
`action`: `valve_open` | `valve_close` | `heater_on` | `heater_off` | `heater_auto`.
`heater_on` boleh punya `args.duration_min` (di-clamp `1..heaterMaxOnMin`).
Response `201`:
```json
{ "id": "c1f2...", "action": "valve_open", "status": "pending", "expires_at": "..." }
```

### `app-settings` (request, partial)
```json
{
  "history_interval_min": 15, "temp_min_c": 30.0, "temp_max_c": 45.0,
  "nh3_mature_ppm": 25.0, "mature_hold_min": 30, "heater_auto": true,
  "valve_max_open_min": 10
}
```
Batas validasi sama seperti skema lama (lihat `functions/_shared/validation.ts`).

## Jobs (`jobs-tick` + Cron tiap menit)
| Tugas | Pemicu | Perilaku |
|---|---|---|
| `sampling` | `history_interval_min` terlewati | Salin `latest_state` → `sensor_readings` |
| `offline-detector` | `now-last_seen > 3×ingest` | `is_online=false` + event (sekali per transisi) |
| `command-expiry` | `pending` lewat TTL | Tandai `expired` |
| `retention` | tiap tick | Hapus `telemetry_raw` > `raw_retention_days` |

Semua idempoten (aman dijalankan tiap menit).

## Telemetry Raw (opsional)
- Jika `raw_retention_days > 0`, setiap ingest disimpan ke `telemetry_raw`.
- Jika `0`, dilewati (hanya histori tersampling).

## Rate Limit & Batas
- `iot-ingest`: ~1 req/detik per device (best-effort per isolate), body ≤16 KB.
- CORS/kuota mengikuti project Supabase.

## Dokumentasi API
- Kontrak ingest: `05-COMMUNICATION-PROTOCOL.md`.
- Setup & uji: `supabase/SETUP.md`, `supabase/tools/sim-curl.sh`.
