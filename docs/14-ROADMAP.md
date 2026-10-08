# 14 — Roadmap

Peta jalan pengembangan, disusun agar bisa maju tanpa menunggu hardware.
Ringkasan checklist ada di `TODO.md` (root proyek).

## Fase 0 — Fondasi & Dokumentasi
- Scaffold proyek Flutter (Android + Web) di root.
- Struktur `lib/`, `docs/`, `server/`, `firmware/`.
- Dokumen rancangan lengkap (folder ini).
- `AGENTS.md` + `TODO.md`.
- **Lulus**: `flutter analyze` bersih; dokumen tersedia.

## Fase 1 — Backend Inti
- Setup Bun + Elysia + Drizzle + MySQL.
- Skema DB + migrasi + seed device.
- Endpoint: health, ingest, live, readings, settings, commands, events.
- Autentikasi device & app.
- Logika bisnis (maturity, thermal, command, event).
- **Lulus**: test server lulus; ingest via curl mengubah `latest_state`.

## Fase 2 — Simulator & Sampling
- Device simulator lengkap (skenario suhu/NH3/offline).
- Job sampling, offline detector, command expiry, retention.
- **Lulus**: menjalankan simulator menghasilkan histori & event realistis.

## Fase 3 — Aplikasi Flutter Inti
- ApiClient + Riverpod + go_router + tema.
- Dashboard, History (fl_chart), Control, Notifications, Settings.
- Polling live & events.
- **Lulus**: aplikasi menampilkan data simulator & mengontrol katup/heater.

## Fase 4 — Integrasi End-to-End (Simulasi)
- Uji skenario penuh: dingin→heater, NH3→matang→notifikasi→bukа katup→auto-close.
- Perbaikan UX & edge case.
- **Lulus**: matriks uji bisnis (`13-TESTING.md`) lulus via simulator.

## Fase 5 — Firmware IoT
- Firmware Mega (sensor, aktuator, state machine, bridge serial).
- Firmware ESP (WiFi, HTTP client, buffer, backoff).
- Protokol Mega↔ESP sesuai `05`.
- **Lulus**: bench test per komponen lulus; telemetry tampil di server.

## Fase 6 — Hardware & HIL
- Perakitan sesuai `03` (wiring, daya, safety).
- Kalibrasi DS18B20 & MQ-137 (R0).
- Uji HIL penuh + checklist.
- **Lulus**: checklist HIL tercentang pada perangkat nyata.

## Fase 7 — Deployment & Pola Akhir
- Docker Compose + Caddy + TLS.
- Konfigurasi ESP ke domain.
- Build APK & Flutter Web.
- Backup, monitoring, dokumentasi akhir.
- **Lulus**: sistem berjalan stabil via domain.

## Estimasi Ketergantungan
```
Fase 0 ──▶ Fase 1 ──▶ Fase 2 ──▶ Fase 3 ──▶ Fase 4
                                   │
                                   └──▶ Fase 5 ──▶ Fase 6 ──▶ Fase 7
```
Fase 1–4 bisa dikerjakan penuh tanpa hardware berkat simulator. Firmware
(Fase 5) menyusul paralel setelah protokol dibekukan.

## Risiko & Mitigasi
| Risiko | Mitigasi |
|---|---|
| Hardware belum siap | Simulator perangkat sejak Fase 2 |
| MQ-137 tidak akurat | Kalibrasi R0 + threshold konfigurabel + beri catatan estimasi |
| Koneksi WiFi labil | Backoff reconnect + buffer telemetry |
| Kontrol lambat (HTTP) | Polling cepat saat ada command pending + TTL |
| Data menumpuk | Retensi `telemetry_raw` + sampling 15 menit |

## Peningkatan Masa Depan (backlog)
- Login multi-user & role.
- Push notification (FCM/Web Push).
- Realtime (SSE/WebSocket) untuk live.
- Platform desktop & iOS.
- Analitik/latih ambang dari data historis (data-driven).
- Kalender/estimasi waktu panen.
