# 05 — Communication Protocol

Dua lapisan protokol:
1. **Serial Mega ↔ ESP8266** — JSON per baris (`\n`), 115200 baud.
2. **HTTP ESP ↔ Server** — REST JSON.

Semua stempel waktu memakai ISO-8601 UTC. Semua payload JSON.

## 1. Serial Mega ↔ ESP8266

- Baud: **115200** 8N1.
- Format: satu objek JSON per baris, diakhiri `\n`. Tidak ada newline di dalam.
- Field `type` menentukan jenis frame.

### Mega → ESP

**Telemetry** (tiap 2 detik / saat berubah)
```json
{"type":"telemetry","seq":1234,"uptime":98765,"temp_c":31.2,"nh3_ppm":18.42,"temp_ok":true,"heater":true,"valve":false,"mode":"AUTO","mature":false}
```

**Event lokal** (mis. safety cutoff)
```json
{"type":"event","code":"SAFETY_CUTOFF","detail":"heater_max_on"}
```

**Ack perintah**
```json
{"type":"ack","id":"c1f2...","ok":true}
```

### ESP → Mega

**Perintah**
```json
{"type":"cmd","id":"c1f2...","action":"valve_open","args":{},"ts":"2026-10-08T10:00:00Z"}
```
`action`: `valve_open` | `valve_close` | `heater_on` | `heater_off` |
`heater_auto` | `set_config`.

**Konfigurasi**
```json
{"type":"config","history_interval_min":15,"ingest_interval_sec":10,"temp_min_c":30.0,"temp_max_c":45.0,"temp_hysteresis_c":2.0,"nh3_mature_ppm":25.0,"mature_hold_min":30,"heater_auto":1,"heater_max_on_min":60,"valve_max_open_min":10,"command_ttl_sec":60}
```

**Ping/keepalive**
```json
{"type":"ping","ts":"2026-10-08T10:00:00Z"}
```

### Aturan
- Jika JSON tidak valid atau `type` tak dikenal → abaikan baris (jangan blok).
- `seq` naik monoton; berguna mendeteksi kehilangan frame.
- Mega membalas `ping` dengan telemetry terbaru.

## 2. HTTP ESP ↔ Server

### `POST /api/iot/ingest`
Header:
```
Content-Type: application/json
X-Device-Key: <device_key>
```

Request:
```json
{
  "seq": 1234,
  "firmware": "0.1.0",
  "ts": "2026-10-08T10:00:05Z",
  "telemetry": {
    "temp_c": 31.2,
    "nh3_ppm": 18.42,
    "temp_ok": true,
    "heater": true,
    "valve": false,
    "mode": "AUTO",
    "mature": false,
    "uptime": 98765
  },
  "events": [
    {"code": "SAFETY_CUTOFF", "detail": "heater_max_on", "ts": "2026-10-08T09:59:00Z"}
  ],
  "acks": [ {"id": "c1f2...", "ok": true} ]
}
```

Response `200`:
```json
{
  "server_time": "2026-10-08T10:00:06Z",
  "config": {
    "ingest_interval_sec": 10,
    "temp_min_c": 30.0,
    "temp_max_c": 45.0,
    "temp_hysteresis_c": 2.0,
    "nh3_mature_ppm": 25.0,
    "mature_hold_min": 30,
    "heater_auto": 1,
    "heater_max_on_min": 60,
    "valve_max_open_min": 10,
    "command_ttl_sec": 60
  },
  "commands": [
    {"id": "c1f2...", "action": "valve_open", "args": {}, "expires_at": "2026-10-08T10:01:05Z"}
  ],
  "poll_after_sec": 5
}
```

Catatan:
- `commands` hanya berisi status `pending` yang belum kedaluwarsa. Server menandai
  `sent` saat dikirim.
- `poll_after_sec` memungkinkan server mempercepat/memperlambat polling.
- Server mengembalikan `config` agar perangkat selalu sinkron.

### Kode Status
| Status | Arti |
|---|---|
| 200 | OK |
| 202 | Diterima, tapi belum diproses (jarang) |
| 400 | Payload tidak valid |
| 401 | `X-Device-Key` salah/tidak ada |
| 429 | Rate limit (device terlalu sering) |
| 5xx | Kesalahan server; ESP retry dengan backoff |

### Backoff ESP
- Gagal kirim → retry 2s, 4s, 8s, 16s, 32s, maks 60s.
- Tetap simpan telemetry terbaru (dan beberapa terakhir) selama offline.

## 3. HTTP Aplikasi ↔ Server (ringkas)
- Auth: `Authorization: Bearer <APP_TOKEN>`.
- Live: `GET /api/live` (polling 10s).
- Events: `GET /api/events?unread=true` (polling 30–60s).
- Kontrol: `POST /api/commands`.
- Histori: `GET /api/readings`.
- Pengaturan: `GET/PUT /api/settings`.

Detail lengkap di `06-BACKEND-API.md`.

## 4. Contoh Uji Cepat (tanpa hardware)
```bash
# Simulasi ingest
curl -X POST http://localhost:3000/api/iot/ingest \
  -H 'Content-Type: application/json' \
  -H 'X-Device-Key: DEVKEY123' \
  -d '{"seq":1,"telemetry":{"temp_c":29.5,"nh3_ppm":12.1,"heater":false,"valve":false,"mode":"AUTO"}}'

# Baca live (app token)
curl http://localhost:3000/api/live -H 'Authorization: Bearer APPT0KEN'
```

## 5. Versi Protokol
- Payload menyertakan `firmware` pada ingest.
- Perubahan breaking akan menaikkan versi API (`/api/v2/...`) dan didokumentasikan
  di sini.
