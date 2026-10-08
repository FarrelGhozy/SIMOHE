# 06 — Backend API

## Stack
- Runtime: **Bun**
- Bahasa: **TypeScript**
- Framework: **Elysia**
- ORM: **Drizzle ORM** + `drizzle-kit` (migrasi)
- Database: **MySQL 8**
- Validasi: **TypeBox** (bawaan pola Elysia) atau skema Drizzle
- Logging: logger terstruktur (pino-like)

## Struktur Proyek (rencana)
```
server/
├── src/
│   ├── index.ts                 # bootstrap Elysia + listen
│   ├── env.ts                   # validasi & muat environment
│   ├── db/
│   │   ├── client.ts            # koneksi mysql2 + drizzle
│   │   └── schema/              # definisi tabel (1 file per tabel) + index.ts
│   ├── middlewares/
│   │   ├── auth-app.ts          # Bearer token
│   │   ├── auth-device.ts       # X-Device-Key
│   │   └── error.ts             # format error seragam
│   ├── modules/
│   │   ├── iot/                 # ingest
│   │   ├── live/
│   │   ├── readings/
│   │   ├── commands/
│   │   ├── settings/
│   │   ├── events/
│   │   ├── batches/
│   │   └── health/
│   ├── services/                # logika bisnis (lihat 09)
│   │   ├── maturity.ts
│   │   ├── thermal.ts
│   │   ├── command.ts
│   │   └── event.ts
│   └── jobs/
│       ├── sampling.ts          # salin live -> histori tiap interval
│       ├── offline-detector.ts
│       └── retention.ts
├── drizzle/                     # migrasi SQL
├── tests/
├── .env.example
├── drizzle.config.ts
├── package.json
└── tsconfig.json
```

## Autentikasi
- **Perangkat**: header `X-Device-Key: <device_key>` (unik per device).
- **Aplikasi**: header `Authorization: Bearer <APP_TOKEN>` (single user).
- Token disimpan di `.env`, tidak pernah di repo.

## Format Error Seragam
```json
{ "error": { "code": "VALIDATION_ERROR", "message": "temp_c wajib angka" } }
```

## Endpoint

### IoT
| Method | Path | Auth | Deskripsi |
|---|---|---|---|
| POST | `/api/iot/ingest` | Device | Kirim telemetry, terima config+commands |
| GET | `/api/iot/ping` | Device | Cek konektivitas (opsional) |

### Monitoring
| Method | Path | Auth | Deskripsi |
|---|---|---|---|
| GET | `/api/live` | App | Nilai terkini + status device |
| GET | `/api/summary?range=24h` | App | min/max/avg suhu & NH3 |
| GET | `/api/readings?from=&to=&bucket=raw\|15m\|1h&limit=` | App | Histori untuk grafik |

### Kontrol
| Method | Path | Auth | Deskripsi |
|---|---|---|---|
| POST | `/api/commands` | App | Antre perintah |
| GET | `/api/commands?status=pending&limit=` | App | Riwayat perintah |
| POST | `/api/commands/:id/cancel` | App | Batalkan perintah pending |

### Pengaturan & Siklus
| Method | Path | Auth | Deskripsi |
|---|---|---|---|
| GET | `/api/settings` | App | Ambil pengaturan |
| PUT | `/api/settings` | App | Ubah pengaturan |
| GET | `/api/batches` | App | Daftar siklus |
| POST | `/api/batches` | App | Mulai siklus baru |
| POST | `/api/batches/:id/harvest` | App | Tandai panen |

### Notifikasi
| Method | Path | Auth | Deskripsi |
|---|---|---|---|
| GET | `/api/events?unread=true&limit=` | App | Daftar event/notifikasi |
| POST | `/api/events/:id/read` | App | Tandai dibaca |
| POST | `/api/events/read-all` | App | Tandai semua dibaca |

### Sistem
| Method | Path | Auth | Deskripsi |
|---|---|---|---|
| GET | `/api/health` | Public | Status server & DB |
| GET | `/api/device` | App | Info device, firmware, last_seen |

## Kontrak Penting

### `GET /api/live` → 200
```json
{
  "device": {
    "id": "1",
    "name": "Reaktor Pupuk 1",
    "online": true,
    "last_seen_at": "2026-10-08T10:00:05Z",
    "firmware": "0.1.0"
  },
  "state": {
    "temp_c": 31.2,
    "nh3_ppm": 18.42,
    "heater_on": true,
    "valve_open": false,
    "mode": "AUTO",
    "status": "heating",
    "updated_at": "2026-10-08T10:00:05Z"
  },
  "maturity": {
    "mature": false,
    "progress": 0.35,
    "threshold_ppm": 25.0,
    "hold_minutes": 30
  }
}
```

### `GET /api/readings` → 200
```json
{
  "bucket": "15m",
  "items": [
    {"ts": "2026-10-08T09:45:00Z", "temp_c": 31.0, "nh3_ppm": 17.8, "heater_on": true, "valve_open": false}
  ]
}
```
- `bucket=raw` hanya tersedia selama retensi mengizinkan.
- `bucket=15m|1h` diagregasi dari `sensor_readings` (avg).

### `POST /api/commands` (request)
```json
{ "action": "valve_open", "args": {} }
```
`action`: `valve_open` | `valve_close` | `heater_on` | `heater_off` | `heater_auto`.
Validasi:
- `heater_on` boleh punya `args.duration_min` (opsional, default dari settings).
Response `201`:
```json
{ "id": "c1f2...", "action": "valve_open", "status": "pending", "expires_at": "2026-10-08T10:01:05Z" }
```

### `PUT /api/settings` (request, partial)
```json
{
  "history_interval_min": 15,
  "temp_min_c": 30.0,
  "temp_max_c": 45.0,
  "nh3_mature_ppm": 25.0,
  "mature_hold_min": 30,
  "heater_auto": true,
  "valve_max_open_min": 10
}
```

## Jobs (Background)
| Job | Interval | Tugas |
|---|---|---|
| `sampling` | `history_interval_min` (default 15m) | Salin `latest_state` → `sensor_readings` |
| `offline-detector` | 30s | Tandai device offline bila lewat ambang; buat event |
| `retention` | harian | Hapus `telemetry_raw` lebih lama dari `raw_retention_days` |
| `command-expiry` | 30s | Tandai command pending yang lewat TTL sebagai `expired` |

## Telemetry Raw (opsional, big data)
- Jika `raw_retention_days > 0`, setiap ingest disimpan ke `telemetry_raw`.
- Jika `0`, tabel raw dilewati (hanya histori tersampling yang disimpan).
- Berguna untuk analitik/threshold data-driven di masa depan.

## CORS & Rate Limit
- CORS mengizinkan origin aplikasi web (dari `.env`).
- Rate limit ingest per device (mis. 1 request/detik) untuk mencegah spam.
- Rate limit endpoint app per token.

## Dokumentasi API
- Sediakan skema OpenAPI (Elysia `swagger` plugin) di `/api/docs` saat dev.

## Catatan Implementasi (Fase 1)
Shape respons aktual yang menyempurnakan kontrak di atas:
- `GET /api/live` menambah `device.location`, `state.temp_ok`, dan
  `maturity.streak_sec`.
- `GET /api/readings` → `{ bucket, from, to, items }`.
  - `raw` diambil dari `telemetry_raw`; `15m` dari `sensor_readings`;
    `1h` agregasi `sensor_readings` per jam (`AVG` suhu/NH3, `MAX` aktuator).
- `GET /api/summary` → `{ from, to, range_count, temp_c:{min,max,avg},
  nh3_ppm:{min,max,avg} }`.
- `GET /api/events` → `{ items, unread_count }`.
- `GET /api/commands` mengembalikan array objek command lengkap
  (`args`, `created_at`, `sent_at`, `acked_at`, `expires_at`).
- `POST /api/commands/:id/cancel` menyetel status `expired` dan menolak (`409`)
  bila command tidak lagi `pending`.
- Ingest menyimpan progres kematangan di `latest_state.mature_streak_sec`
  (lihat `docs/09`); gap data > 3× `ingest_interval_sec` mereset streak.
- Event `SAFETY_CUTOFF` dari perangkat dipetakan ke event `safety_cutoff`.
- Rate limit dikonfigurasi `RATE_LIMIT_INGEST_PER_SEC` (per device) dan
  `RATE_LIMIT_APP_PER_SEC` (per token) di `.env`.
