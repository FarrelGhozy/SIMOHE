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

## Fase 5 — Firmware IoT `P0`
- [ ] Struktur `firmware/mega/simohe_mega/`
- [ ] Driver DS18B20 (OneWire + filter)
- [ ] Driver MQ-137 (Rs/R0 → ppm) + kalibrasi R0 + EEPROM
- [ ] Aktuator relay K1/K2 + safety
- [ ] State machine `docs/09` (non-blocking `millis()`)
- [ ] Bridge Serial JSON ke ESP
- [ ] Struktur `firmware/esp8266/simohe_esp/`
- [ ] WiFi + HTTP client (ingest)
- [ ] Parser commands + ack
- [ ] Buffer offline + backoff reconnect
- [ ] Watchdog
- [ ] Bench test per komponen

---

## Fase 6 — Hardware & HIL `P0`
- [ ] Perakitan wiring sesuai `docs/03`
- [ ] Proteksi daya (fuse, flyback diode)
- [ ] Kalibrasi DS18B20 vs termometer referensi
- [ ] Kalibrasi MQ-137 (preheat 24–48 jam, R0)
- [ ] Checklist HIL `docs/13` tercentang
- [ ] Uji fail-safe (sensor dicabut, WiFi dicabut, server mati)

---

## Fase 7 — Deployment & Polish `P0`
- [ ] `server/Dockerfile` + `docker-compose.yml`
- [ ] `Caddyfile` (HTTPS otomatis) + domain
- [ ] Migrasi & seed di server produksi
- [ ] Konfigurasi ESP ke domain (HTTPS)
- [ ] Build APK (`flutter build apk`) & Web (`flutter build web`)
- [ ] Backup DB terjadwal + uji restore
- [ ] Monitoring health & log
- [ ] README & dokumen final diperbarui

---

## Backlog / Peningkatan `P2`
- [ ] Login multi-user + role (admin/operator)
- [ ] Push notification (FCM / Web Push)
- [ ] Realtime live via SSE/WebSocket
- [ ] Platform desktop (Windows/Linux) & iOS/macOS
- [ ] Analitik ambang data-driven dari histori
- [ ] Estimasi waktu panen
- [ ] CI/CD (GitHub Actions)
