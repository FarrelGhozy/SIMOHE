# TODO — SIMOHE

Checklist pengerjaan per fase. Tandai `[x]` saat selesai. Rujukan desain ada di
`docs/`. Aturan kerja ada di `AGENTS.md`.

Legenda prioritas: `P0` wajib, `P1` penting, `P2` opsional.

---

## Fase 0 — Fondasi & Dokumentasi `[selesai]`
- [x] Scaffold proyek Flutter di root (Android + Web)
- [x] Struktur `lib/core`, `lib/features`, `lib/shared`
- [x] Buat `.gitignore` untuk Flutter + Bun + env
- [x] Arsipkan proyek lama ke `docs/reference/legacy/`
- [x] Hapus kode Android lama (`app/`, `gradle/`, dll)
- [x] Tulis `AGENTS.md`
- [x] Tulis `TODO.md`
- [x] Dokumen rancangan `docs/00`–`docs/14`
- [x] `flutter analyze` bersih

---

## Fase 1 — Backend Inti (Bun + Elysia + MySQL) `[selesai]`
- [x] Inisialisasi `server/` (package.json, tsconfig strict, Elysia)
- [x] Setup `.env.example` + loader env + validasi
- [x] Setup Drizzle + `mysql2` + `drizzle.config.ts`
- [x] Tulis skema `db/schema.ts` sesuai `docs/07`
- [x] Generate & jalankan migrasi (`db:generate`, `db:migrate`)
- [x] Seed device + `settings` + batch awal
- [x] Middleware auth device (`X-Device-Key`) & app (`Bearer`)
- [x] Middleware error seragam `{ error: { code, message } }`
- [x] Endpoint `GET /api/health`
- [x] Endpoint `POST /api/iot/ingest` (+ config/commands response)
- [x] Endpoint `GET /api/live`
- [x] Endpoint `GET /api/readings` (raw & agregasi)
- [x] Endpoint `GET/PUT /api/settings`
- [x] Endpoint `POST /api/commands` + `GET /api/commands` + cancel
- [x] Endpoint `GET /api/events` + read/read-all
- [x] Endpoint `GET /api/summary`, `GET /api/device`, `/api/batches`
- [x] Service `maturity.ts` (lihat `docs/09`)
- [x] Service `thermal.ts`
- [x] Service `command.ts` (TTL & status)
- [x] Service `event.ts` (dedup per transisi)
- [x] Swagger/OpenAPI di `/api/docs` (dev)
- [x] Rate limit + CORS
- [x] Unit test service + integration test endpoint
- [x] `bun test`, `bun run lint`, `bun run typecheck` lulus

---

## Fase 2 — Simulator & Job Background `[selesai]`
- [x] `server/tools/simulator.ts` (skenario suhu, NH3, offline)
- [x] Simulator menerima & meng-ack commands
- [x] Job `sampling` (default 15 menit, dari settings)
- [x] Job `offline-detector`
- [x] Job `command-expiry`
- [x] Job `retention` (bersihkan `telemetry_raw`)
- [x] Verifikasi histori & event muncul dari simulator

---

## Fase 3 — Aplikasi Flutter Inti `[selesai]` `P0`
- [x] Tambah dependensi: riverpod, go_router, dio, freezed, json_serializable, fl_chart, intl, shared_preferences
- [x] `core/network/api_client.dart` (Dio + token + error mapping)
- [x] `core/router/app_router.dart` (shell bottom nav / rail)
- [x] Model domain `shared/models` (device, state, reading, event, settings)
- [x] Repository + provider per fitur
- [x] **Dashboard**: kartu suhu, NH3, status, koneksi, kontrol cepat, mini chart
- [x] **History**: grafik suhu & NH3, pemilih rentang, ringkasan min/max/avg, ekspor CSV (web)
- [x] **Control**: katup (konfirmasi + TTL info), heater (auto/on/off)
- [x] **Notifications**: daftar event, filter belum dibaca, tandai dibaca
- [x] **Settings**: interval sampling/ingest, ambang suhu & NH3, mode heater
- [x] **Device**: status, firmware, last_seen
- [x] Tema & widget bersama (`StatusBadge`, `MetricCard`, `TrendChart`)
- [x] Polling live (10s) & events (30–60s)
- [x] Cache offline (shared_preferences)
- [x] Widget test + unit test
- [x] `flutter analyze` bersih

---

## Fase 4 — Integrasi End-to-End (Simulasi) `[selesai]` `P0`
- [x] Jalankan server + simulator + app bersamaan
- [x] Uji T1–T10 pada `docs/13-TESTING.md`
- [x] Perbaiki edge case (device offline, command expired, dll)
- [x] Uji notifikasi matang tanpa membuka katup otomatis
- [x] Uji auto-close katup & safety heater

---

## Branding & Aset Visual `[selesai]`
- [x] Dokumentasi brand `docs/15-BRANDING.md` (palet, aturan logo, inventaris)
- [x] Aset brand teroptimasi: emblem + logo monochrome (`assets/branding/`)
- [x] Tema hijau brand `#084E34` + komponen `BrandIcon`
- [x] Emblem di AppBar; ikon UI memakai Material Icons bawaan
- [x] Ikon aplikasi Android & web (launcher, favicon, manifest)
- [x] Splash screen Android memakai emblem (`flutter_native_splash`, web: false)

---

## Fase 5 — Firmware IoT `[selesai]` `P0`
- [x] Struktur `firmware/mega/simohe_mega/`
- [x] Driver DS18B20 (OneWire + filter)
- [x] Driver MQ-137 (Rs/R0 → ppm) + kalibrasi R0 + EEPROM
- [x] Aktuator relay K1/K2 + safety
- [x] State machine `docs/09` (non-blocking `millis()`)
- [x] Bridge Serial JSON ke ESP
- [x] Struktur `firmware/esp8266/simohe_esp/`
- [x] WiFi + HTTP client (ingest)
- [x] Parser commands + ack
- [x] Buffer offline + backoff reconnect
- [x] Watchdog
- [x] Unit test logika host (`pio test -e native`) + build kedua target
- [x] Hardening audit 2026-10-13 (lihat `docs/16-FIRMWARE-FIX.md`): latch max-on
  10 mnt, edge-trigger safety, sanitize config + CRC EEPROM, parser anti-OOB,
  readLine anti-split, offline tolak-truncate, `nh3_ok`, `timeReached()`,
  expiry-defer, drop-400, serial buffer 256 dua sisi (Mega 22 test, ESP 13 test)
- [ ] Bench test per komponen → dipindah ke Fase 6 (butuh hardware)

---

## Fase 6 — Hardware & HIL `P0`
- [x] Flash firmware Mega + ESP (board RobotDyn MEGA+WiFi R3, Mega↔ESP di Serial3)
- [x] HIL awal: telemetry Mega→ESP→server→DB (device online, firmware 0.1.0)
- [x] HIL: perintah app end-to-end `pending→sent→acked` (heater_on/auto)
- [x] Uji fail-safe sensor absen: status `error`, heater & valve OFF
- [ ] Perakitan wiring sesuai `docs/03`
- [ ] Proteksi daya (fuse, flyback diode)
- [ ] Bench test per komponen (DS18B20, MQ-137, relay, Serial Mega↔ESP)
- [ ] Kalibrasi DS18B20 vs termometer referensi
- [ ] Kalibrasi MQ-137 (preheat 24–48 jam, R0)
- [ ] Checklist HIL `docs/13` tercentang
- [ ] Uji fail-safe (sensor dicabut, WiFi dicabut, server mati)

---

## Fase 7 — Deployment & Polish `P0` `[dibatalkan → diganti Fase 8]`
- [ ] `server/Dockerfile` + `docker-compose.yml`
- [ ] `Caddyfile` (HTTPS otomatis) + domain
- [ ] Migrasi & seed di server produksi
- [ ] Konfigurasi ESP ke domain (HTTPS)
- [ ] Build APK (`flutter build apk`) & Web (`flutter build web`)
- [ ] Backup DB terjadwal + uji restore
- [ ] Monitoring health & log
- [ ] README & dokumen final diperbarui
> **Catatan 2026-10-14**: Fase 7 berbasis VPS/Docker **dibatalkan**. Backend
> diganti ke **Supabase-only** (lihat Fase 8). Jangan kerjakan Fase 7.

---

## Fase 8 — Migrasi Supabase-only `P0` `[aktif]`
Rujukan utama: `docs/17-SUPABASE-MIGRATION.md`. Prinsip: tidak overkill —
3 Edge Functions saja, read langsung PostgREST, Realtime opsional dengan
fallback polling. Katup WAJIB tetap bisa dipakai (pending→sent→acked).

### 8.0 Arsip server lama (jaga-jaga, jangan hapus)
- [x] `git mv server docs/reference/archive/server-bun-2026-10-14/`
- [x] Pastikan `flutter analyze` + `pio test -e native` tetap hijau tanpa `server/`
- [x] Catat commit hash server terakhir di `docs/17` § Arsip

### 8.1 Supabase schema dari nol (Free tier)
- [x] Buat project Supabase baru (region terdekat, mis. Singapore)
- [x] Tulis `supabase/migrations/0001_init.sql` (porting `docs/07` MySQL→Postgres:
      devices, latest_state, telemetry_raw, sensor_readings, settings,
      commands (`id` uuid), events, batches; `timestamptz` UTC, `payload` jsonb,
      index komposit)
- [x] Enable RLS semua tabel; policy: `anon` hanya `SELECT`, write hanya
      `service_role` (via Edge Function)
- [x] Tulis `supabase/seed.sql` (1 device + settings default + batch fermenting)
- [x] Verifikasi di SQL Editor: tabel + RLS aktif

### 8.2 Edge Function `iot-ingest` (pengganti `POST /api/iot/ingest`)
- [x] `supabase/functions/iot-ingest/index.ts` (Deno): auth `X-Device-Key`
      (bandingkan hash sha256), validasi range (temp -20..120, nh3 0..1000,
      body ≤16KB), format error `{ error: { code, message } }`
- [x] Porting `maturity.ts` + `thermal.ts` + `event.ts` 1:1 (streak, progress,
      event sekali per transisi, gap >3× ingest reset streak)
- [x] Ambil commands `pending` belum expired → tandai `sent`; proses `acks` →
      `acked` + event valve/heater
- [x] Respons `{ server_time, config, commands, poll_after_sec }` (kontrak
      `docs/05` tidak berubah)
- [x] Set secrets: `DEVICE_KEY_HASH`, `SUPABASE_DB_*` bila perlu; deploy +
      uji via `curl` (200, 400, 401)

### 8.3 Edge Functions `app-command` / `app-settings` / `app-batch`
- [x] `supabase/functions/app-command/`: whitelist action, clamp
      `duration_min` 1..heaterMaxOnMin, `expires_at = now + command_ttl_sec`,
      cancel hanya bila `pending` (409 bila tidak)
- [x] `supabase/functions/app-settings/` + `app-batch/`: validasi batas wajar
- [x] Uji: `valve_open` → `pending` → diambil ingest → `sent` → ack → `acked`

### 8.4 Job `jobs-tick` + Cron (pengganti job in-process)
- [x] `supabase/functions/jobs-tick/`: sampling (latest→readings bila
      `history_interval_min` terlewati), offline-detector
      (>3× ingest → `is_online=false` + event), command-expiry, retention
- [x] Daftarkan Scheduled Cron tiap 1 menit (Dashboard → Edge Functions → Cron)
- [x] Verifikasi: histori muncul, event offline/online, command expired

### 8.5 Flutter → `supabase_flutter` (tanpa login)
- [x] Tambah `supabase_flutter` ke `pubspec.yaml` (cek dulu, jangan dobel)
- [x] Ganti `ApiClient` Dio → `SupabaseClient`: `SUPABASE_URL` +
      `SUPABASE_PUBLISHABLE_KEY` via `--dart-define` (hapus `API_BASE_URL`/`APP_TOKEN`)
- [x] Repository per fitur → PostgREST `select` (live, readings, events,
      settings, commands, device, batches); write via `functions.invoke`
- [x] Pertahankan polling 10/30/5 dtk sebagai fallback; tambah Realtime
      subscribe (latest_state/events/commands) bila mudah
- [x] `flutter analyze` + `flutter test` bersih

### 8.6 Firmware ESP (minim, Mega jangan disentuh)
- [x] `config.h`: `SIMOHE_INGEST_PATH` → `/functions/v1/iot-ingest`
- [x] `api_client.cpp`: tambah header `apikey` + `Authorization: Bearer <anon>`,
      `BASE_URL` → `https://<ref>.supabase.co` dari `secrets.h`
      (`SIMOHE_BASE_URL`, `SIMOHE_ANON_KEY`, `SIMOHE_DEVICE_KEY`)
- [x] Pertahankan buffer offline 8×1024, backoff, drop-400
- [x] `pio test -e native` + `pio run -e esp` lulus

### 8.7 Docs & rilis Supabase
- [x] Update `docs/00,02,05,06,07,08,11,12,13,14` + `AGENTS.md` (Backend: Supabase)
- [x] Tulis `supabase/SETUP.md` final (langkah dashboard → migration → secrets → cron)
- [ ] Uji matriks T1–T10 `docs/13` via Edge Function + app (butuh project Supabase)
- [ ] Build APK + Web dengan `--dart-define=SUPABASE_URL/PUBLISHABLE_KEY`
- [ ] Backup terjadwal Supabase (daily backup / PITR) + uji restore

---

## Revisi Aplikasi — Refresh & Notifikasi `[selesai]`
- [x] Dashboard: tren 24 jam jadi `AsyncNotifier` (polling + Realtime
      `sensor_readings`), ikut tombol/pull-to-refresh dan `ref.listen`
      perubahan interval
- [x] Pengaturan → Aplikasi: interval ambil data (Live/Notifikasi/Perintah/Tren)
      tersimpan lokal (`shared_preferences`), diterapkan ke semua notifier
- [x] Notifikasi sistem lokal Android (`flutter_local_notifications`) untuk
      event baru + permission `POST_NOTIFICATIONS` + desugaring Gradle
- [x] Preferensi notifikasi lokal (aktif/nonaktif, hanya warning ke atas)
- [x] Tap notifikasi → bottom sheet detail + aksi kontekstual + umpan balik
      "ditandai dibaca"; "tandai semua" berkonfirmasi; filter belum dibaca
      disimpan; empty state lebih jelas
- [x] Deep link `/notifications?id=<id>` dari tap notifikasi sistem
- [x] Unit/widget test baru; `flutter analyze` + `flutter test` bersih
- [ ] Verifikasi di perangkat Android (notifikasi tray + permission) — butuh
      build fisik

---

## Fitur Analisis Stabilitas NH3 `[sebagian]`
- [x] Tab navbar Notifikasi → Analisis (ikon tabung `science_outlined`)
- [x] Lonceng notifikasi di top bar semua tab utama (`NotificationBell`)
- [x] `/notifications` jadi rute root (luar shell) + detail bottom sheet tetap
- [x] Kalkulator stabilitas client-only (`stability_calc`) + unit test
- [x] Guard nol/null/mac et/offline/error → tanpa notifikasi
- [x] Pengaturan lokal window/ambang/toleransi/cek-otomatis
- [x] Grafik gelombang + dinding tabung + rekapan Dashboard
- [x] Ikon launcher adaptive diperbaiki (foreground rusak → tile full-color)
- [ ] Kalibrasi lapangan 3–5 hari (tentukan default `range_max`/`threshold`)
- [ ] Nonaktifkan logika matang ambang lama di `iot-ingest` setelah kalibrasi
- [ ] Verifikasi di perangkat Android (ikon terinstal + notifikasi tray)

---

## Backlog / Peningkatan `P2`- [ ] Login multi-user + role (admin/operator)
- [ ] Push notification (FCM / Web Push)
- [ ] Realtime live via SSE/WebSocket
- [ ] Platform desktop (Windows/Linux) & iOS/macOS
- [ ] Analitik ambang data-driven dari histori
- [ ] Estimasi waktu panen
- [ ] CI/CD (GitHub Actions)
