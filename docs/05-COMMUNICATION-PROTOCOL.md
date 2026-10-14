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
{"type":"telemetry","seq":1234,"uptime":98765,"temp_c":31.2,"nh3_ppm":18.42,"temp_ok":true,"nh3_ok":true,"heater":true,"valve":false,"mode":"AUTO","mature":false}
```
`temp_c`/`nh3_ppm` bernilai `null` bila sensor gagal (`temp_ok`/`nh3_ok`
bernilai `false`). `uptime` dalam detik.

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
{"type":"cmd","id":"c1f2...","action":"valve_open","args":{},"expires_epoch":1791453665}
```
`action`: `valve_open` | `valve_close` | `heater_on` | `heater_off` |
`heater_auto`. Untuk `heater_on`, `args` berisi `duration_min` (di-clamp
`1..heaterMaxOnMin`, maks 1440). Expiry dikirim sebagai `expires_epoch`
(utama) atau `expires_at` ISO-8601 (kompatibel); kedua format diterima Mega+ESP.
`id`/`action` yang melebihi kapasitas (`37`/`16`) ditolak agar `ack` cocok.

Catatan:
- Konfigurasi **bukan** perintah. Server mengirim `config` melalui respons
  `POST /api/iot/ingest`; ESP meneruskannya ke Mega sebagai frame `config`.
  (Versi lama menyebut `set_config` — **tidak dipakai**.)
- ESP menyertakan `expires_epoch` (epoch detik UTC) agar Mega yang tidak punya
  RTC tetap dapat mengabaikan perintah kedaluwarsa. Server juga sudah tidak
  mengirim perintah `pending` yang lewat TTL.

**Konfigurasi**
```json
{"type":"config","ingest_interval_sec":10,"temp_min_c":30.0,"temp_max_c":45.0,"temp_hysteresis_c":2.0,"nh3_mature_ppm":25.0,"mature_hold_min":30,"heater_auto":1,"heater_max_on_min":60,"valve_max_open_min":10,"command_ttl_sec":60}
```
`heater_auto` menerima `0/1` atau `true/false`. Semua field disanitasi
(`sanitizeHeaterConfig`); nilai liar di-clamp. `history_interval_min` tidak
dipakai (sampling di server).

**Ping/keepalive**
```json
{"type":"ping"}
```
Mega membalas dengan telemetry (`seq` increment agar tetap monoton).

### Aturan
- Jika JSON tidak valid atau `type` tak dikenal → abaikan baris (jangan blok).
  Baris >511 char dibuang utuh. `mode` harus `AUTO`/`FORCE_ON`/`FORCE_OFF`
  (case-insensitive, harus penuh).
- `seq` naik monoton (termasuk balasan ping); berguna mendeteksi kehilangan frame.
- Mega membalas `ping` dengan telemetry terbaru.

## 2. HTTP ESP ↔ Supabase

### `POST /functions/v1/iot-ingest`
Base URL: `https://<ref>.supabase.co` (wajib HTTPS).
Header:
```
Content-Type: application/json
apikey: <SUPABASE_PUBLISHABLE_KEY>
Authorization: Bearer <SUPABASE_PUBLISHABLE_KEY>
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
    "nh3_ok": true,
    "heater": true,
    "valve": false,
    "mode": "AUTO",
    "mature": false,
    "uptime": 98765
  },
  "events": [
    {"code": "SAFETY_CUTOFF", "detail": "heater_max_on"}
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
- `ts` dari perangkat bersifat **informasional**; server memakai waktu terimanya
  (UTC) untuk `last_seen_at`, penyimpanan `telemetry_raw`, dan penjadwalan
  sampling. Stempel waktu yang dipakai untuk penanggalan tetap waktu server.

### Kode Status
| Status | Arti |
|---|---|
| 200 | OK |
| 400 | Payload tidak valid |
| 401 | `X-Device-Key` salah/tidak ada, atau kunci Supabase salah |
| 429 | Rate limit (device terlalu sering, ~1 req/detik) |
| 5xx | Kesalahan function; ESP retry dengan backoff |

### Backoff ESP
- Gagal kirim → retry 2s, 4s, 8s, 16s, 32s, maks 60s.
- Buffer offline: 8 frame ingest penuh (`8x1024`). Replay maks 5/ingest.
- `400` tidak di-retry/di-buffer (payload busuk dibuang); `429/5xx`/gagal koneksi di-buffer.

## 3. HTTP Aplikasi ↔ Supabase (ringkas)
- Tanpa login: publishable key + RLS read-only.
- Live: gabungan `devices` + `latest_state` + `settings` (PostgREST) +
  Realtime `latest_state` (fallback polling 10s).
- Events: tabel `events` (polling 30s + Realtime); tandai dibaca via UPDATE
  `is_read` (dibatasi trigger, lihat migrasi `0002`).
- Kontrol: Edge Function `app-command` (POST command + cancel).
- Histori: `sensor_readings` (`15m`) / `telemetry_raw` (`raw`); bucket `1h`
  diagregasi di aplikasi.
- Pengaturan: baca tabel `settings`, tulis via Edge Function `app-settings`.

Detail lengkap di `06-BACKEND-API.md`.

## 4. Contoh Uji Cepat (tanpa hardware)
```bash
# Simulasi ingest (lihat juga supabase/tools/sim-curl.sh)
curl -X POST https://<ref>.supabase.co/functions/v1/iot-ingest \
  -H 'Content-Type: application/json' \
  -H 'apikey: <PUBLISHABLE_KEY>' \
  -H 'Authorization: Bearer <PUBLISHABLE_KEY>' \
  -H 'X-Device-Key: <DEVICE_KEY>' \
  -d '{"seq":1,"telemetry":{"temp_c":29.5,"nh3_ppm":12.1,"heater":false,"valve":false,"mode":"AUTO"}}'

# Baca live (publishable key, RLS read-only)
curl 'https://<ref>.supabase.co/rest/v1/latest_state?select=*' \
  -H 'apikey: <PUBLISHABLE_KEY>' -H 'Authorization: Bearer <PUBLISHABLE_KEY>'
```

## 5. Versi Protokol
- Payload menyertakan `firmware` pada ingest.
- Perubahan breaking akan menaikkan versi API (`/api/v2/...`) dan didokumentasikan
  di sini.
