# 17 — Migrasi Supabase-only

> **Status**: aktif (2026-10-14). Menggantikan backend Bun+Elysia+MySQL
> (Fase 1–2, 7) dengan **Supabase Free tier**. Rujukan eksekusi: `TODO.md`
> Fase 8. Server lama diarsipkan di `docs/reference/archive/server-bun-*/`
> (jaga-jaga, jangan dihapus).

## 1. Keputusan Final

| Aspek | Keputusan |
|---|---|
| Project Supabase | Baru dari nol, Free tier, region Singapore (atau terdekat) |
| Auth app | Tetap **tanpa login** — `publishable key` langsung, tanpa Supabase Auth |
| Ingest ESP | **Edge Function** `iot-ingest` (kontrak `docs/05` tidak berubah) |
| Logika bisnis | Porting 1:1 `maturity/thermal/command/event.ts` ke Deno (tidak overkill) |
| Read app | Langsung **PostgREST** (`SELECT`) |
| Write app | Via Edge Function (`app-command`, `app-settings`, `app-batch`) |
| Jobs | 1 Edge Function `jobs-tick` + **Scheduled Cron tiap 1 menit** |
| Realtime | Enhancement; **polling lama tetap sebagai fallback** |
| Katup | WAJIB end-to-end `pending→sent→acked` + TTL + auto-close safety |

## 2. Arsitektur Baru

```
Mega <--Serial JSON--> ESP --HTTPS--> Supabase Edge Function iot-ingest
                                              │ service_role
                                              ▼
                                    Postgres (8 tabel + RLS)
                                              ▲
Flutter (supabase_flutter, anon, tanpa login) ┤ PostgREST SELECT
  + functions.invoke (write) + Realtime (opsional, fallback polling)
Cron 1 mnt --> jobs-tick (sampling, offline, expiry, retention)
```

Perubahan vs `docs/02`: hapus container Bun + MySQL host + Caddy;
ganti dengan project Supabase. Mega tidak berubah. ESP hanya ganti
URL + 2 header.

## 3. Kontrak yang TIDAK Berubah (agar firmware minim)

Request ESP (body JSON sama seperti `docs/05` §2):
`{seq, firmware, ts, telemetry{temp_c, nh3_ppm, temp_ok, nh3_ok, heater,
valve, mode, mature, uptime}, events[], acks[]}`.

Header baru:
```
apikey: <SUPABASE_PUBLISHABLE_KEY>
Authorization: Bearer <SUPABASE_PUBLISHABLE_KEY>
X-Device-Key: <device_key plaintext>
Content-Type: application/json
```

URL baru: `https://<ref>.supabase.co/functions/v1/iot-ingest`.

Respons tetap:
`{server_time, config{ingest_interval_sec, temp_min_c, temp_max_c,
temp_hysteresis_c, nh3_mature_ppm, mature_hold_min, heater_auto,
heater_max_on_min, valve_max_open_min, command_ttl_sec}, commands[{id,
action, args, expires_at}], poll_after_sec}`.

Error seragam: `{ error: { code, message } }` (400 validasi, 401 device key,
429 rate limit).

## 4. Skema Postgres (porting `docs/07`)

File: `supabase/migrations/0001_init.sql`. Aturan konversi MySQL→Postgres:

- `DATETIME` → `timestamptz` (selalu UTC, `now()`).
- `BIGINT UNSIGNED AUTO_INCREMENT` → `bigint generated always as identity`.
- `TINYINT(1)` → `boolean`.
- `DECIMAL(5,2)` / `(8,3)` tetap.
- `commands.id CHAR(36)` → `uuid primary key default gen_random_uuid()`.
- `payload JSON` → `jsonb`.
- Enum tetap `varchar` + validasi di Edge Function (sama seperti Elysia schema).
- Index komposit `(device_id, recorded_at/sampled_at/created_at)` tetap.
- `latest_state` & `settings` 1:1 dengan `devices` (FK + unique).
- `device_key` simpan sebagai `char(64)` berisi **hash SHA-256 hex**;
  plaintext hanya di firmware `secrets.h` + secrets Edge Function sekali saat seed.

Seed: `supabase/seed.sql` — 1 device, 1 settings default (`docs/09`),
1 batch `fermenting`.

## 5. RLS (tanpa login, minimal aman)

```sql
alter table <semua> enable row level security;
-- anon: hanya baca (single user tanpa login)
create policy "anon_select" on <tabel_app>
  for select to anon using (true);
-- tulis: hanya service_role (Edge Function), tanpa policy anon insert/update/delete
```

`service_role` tidak pernah ke firmware/app. `publishable key` memang public —
keamanannya dari: HTTPS wajib, RLS read-only, semua tulis tervalidasi di
Edge Function, `device_key` 32 char acak + hash, TTL perintah, rate limit
sederhana di `iot-ingest` (1 req/detik per device, best-effort).

Pengecualian: tandai event dibaca (`is_read`) boleh di-UPDATE langsung oleh
publishable key via migrasi `0002_events_read.sql` (policy + trigger guard:
hanya kolom `is_read` yang boleh berubah). Opsional: bila secret
`APP_WRITE_KEY` diset, Edge Functions tulis + cron wajib header `X-App-Key`.

## 6. Edge Functions (3 saja)

```
supabase/functions/
├── iot-ingest/index.ts     # §3 + porting maturity/thermal/event/command
├── app-command/index.ts    # POST command + cancel (TTL, whitelist, clamp)
├── app-settings/index.ts   # PUT settings (batas wajar)
├── app-batch/index.ts      # start/harvest batch
└── jobs-tick/index.ts      # sampling + offline + expiry + retention
```

Bersama: `_shared/auth.ts` (cek device key), `_shared/validation.ts`
(range), `_shared/errors.ts` (format error). Deno + `strict`, `npm:`
atau JSR Supabase client dengan `service_role` dari `Deno.env`.

`jobs-tick` dipicu **Scheduled Cron tiap menit** (Dashboard → Edge
Functions → Cron → `select net.http_post(...)` atau integrasi Cron
baru). Idempoten: sampling hanya bila `history_interval_min` terlewati
(cek `max(sampled_at)`), event offline/online sekali per transisi,
expiry `where status='pending' and expires_at < now()`.

## 7. Flutter

- Dep: tambah `supabase_flutter` saja (cek `pubspec.yaml` dulu).
- `AppConfig`: hapus `apiBaseUrl/appToken`, ganti:
  `SUPABASE_URL` + `SUPABASE_PUBLISHABLE_KEY` via `--dart-define`.
- `ApiClient` Dio → `SupabaseClient` singleton (`Supabase.instance.client`).
- Mapping modul lama → PostgREST:
  `live` → `devices` join `latest_state`; `readings` → `sensor_readings`
  (+ `telemetry_raw` bila retensi); `events` → `events order created_at desc`;
  `settings/device/batches/summary` → tabel masing-masing / agregasi client.
- Write: `functions.invoke('app-command', body: {...})`, dst.
- Polling 10/30/5 dtk dipertahankan; Realtime (`channel.onPostgresChanges`)
  untuk `latest_state/events/commands` bila tidak menambah kompleksitas.
- Perintah run baru:
  ```bash
  flutter run -d chrome --dart-define=SUPABASE_URL=https://<ref>.supabase.co \
    --dart-define=SUPABASE_PUBLISHABLE_KEY=<anon>
  ```

## 8. Firmware ESP (minim)

- `config.h`: `SIMOHE_INGEST_PATH` → `"/functions/v1/iot-ingest"`.
- `api_client.cpp`: tambah `apikey` + `Authorization`, `BASE_URL` dari
  `secrets.h` (`SIMOHE_BASE_URL=https://<ref>.supabase.co`,
  `SIMOHE_ANON_KEY`, `SIMOHE_DEVICE_KEY`).
- Selain itu tidak berubah: buffer 8×1024, backoff 2→60 dtk, drop-400,
  replay maks 5/ingest, safety di Mega.
- Utang: `setInsecure()` tetap sementara (Supabase wajib HTTPS);
  catat pinning CA/fingerprint sebagai backlog.

## 9. Arsip Server Lama

```bash
git mv server docs/reference/archive/server-bun-2026-10-14/
# catat hash: git log --oneline -1 -- server >> docs/17 (saat eksekusi)
```

> **Arsip 2026-10-14**: `server/` dipindah ke
> `docs/reference/archive/server-bun-2026-10-14/` (commit terakhir server:
> `87d4f85 fix(server): temp_ok fallback + updated_at eksplisit di ingest`).
> `node_modules/` dihapus dari arsip (install ulang via `bun.lock` bila perlu);
> `.env` arsip tetap di-ignore (tidak ikut commit).

`server/tools/simulator.ts` ikut terarsip — agent Fase 8 membuat
`supabase/tools/sim-curl.sh` (curl ingest + ack) sebagai pengganti
sementara hingga simulator Deno/Flutter tersedia. Jangan pakai logika
server lama selain sebagai referensi porting.

## 10. Uji Penerimaan (wajib sebelum Done)

1. `curl` ingest normal → 200 + `config` + `commands[]`.
2. Suhu 27 °C → event `temp_low`; 46 °C → `safety_cutoff`.
3. NH3 ≥ ambang 30 mnt → event `mature`, katup **tetap tertutup**.
4. App `valve_open` → `pending→sent→acked` + event `valve_open`.
5. Command lewat TTL → `expired`, tidak dikirim.
6. Katup > `valve_max_open_min` → auto-close (firmware/sim).
7. Tanpa ingest >3× interval → `device_offline`; ingest lagi → `device_online`.
8. Sampling → `sensor_readings` bertambah per interval.
9. `flutter analyze` + `flutter test` + `pio test -e native` hijau.
10. Build APK + Web dengan `SUPABASE_*` defines.

Bukti dicatat di `docs/13-TESTING.md` § Baru (ganti hasil Fase 4 lama
yang berbasis Bun).

## 11. Batas Free Tier & Mitigasi

| Batas | Mitigasi |
|---|---|
| Invokasi Edge Function | ingest 10 dtk tetap; `poll_after_sec` naikkan saat idle |
| Koneksi Realtime | polling tetap ada; Realtime reconnect + fallback |
| Ukuran DB | `raw_retention_days` default kecil (mis. 7) atau 0 |
| Cron | 1 job/menit saja, bukan 30 dtk |

## 12. File yang Harus Ada Saat Fase 8 Selesai

```
supabase/
├── README.md
├── SETUP.md                # panduan klik-per-klik (project → cron → app)
├── .env.example            # SUPABASE_URL, PUBLISHABLE_KEY (tanpa secret)
├── config.toml             # verify_jwt=false per function
├── migrations/
│   ├── 0001_init.sql       # 8 tabel + RLS publishable SELECT
│   └── 0002_events_read.sql# UPDATE is_read + trigger guard
├── seed.sql
├── cron.sql                # Scheduled Cron jobs-tick tiap menit
└── functions/{iot-ingest,app-command,app-settings,app-batch,jobs-tick}/index.ts
    + functions/_shared/{errors,db,auth,logic,validation}.ts
```

Dokumen yang direvisi pada Fase 8 (2026-10-14):
`00,02,05,06,07,08,11,12,13,14` + `AGENTS.md` + `TODO.md` + `supabase/SETUP.md`.
`docs/09` (algoritma) dan `docs/10` (event) tidak berubah perilaku.
