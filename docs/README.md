# Dokumentasi SIMOHE

Kumpulan dokumen rancangan (design) untuk rebuild proyek **SIMOHE** — Sistem
Monitoring Pengolahan Kotoran Hewan berbasis IoT (Flutter + Supabase +
Arduino Mega & ESP8266).

> **Migrasi 2026-10-14**: backend Bun/Elysia + MySQL **diganti Supabase-only**
> (lihat `17-SUPABASE-MIGRATION.md`, `TODO.md` Fase 8). Dokumen `02,05,06,07,`
> `08,11,12` yang masih menyebut Bun/MySQL adalah **arsip pra-migrasi** dan
> direvisi oleh agent Fase 8. Server lama diarsipkan di
> `reference/archive/server-bun-*/`.

## Urutan Baca
1. [00 — Project Overview](00-PROJECT-OVERVIEW.md)
2. [01 — Requirements](01-REQUIREMENTS.md)
3. [02 — System Architecture](02-SYSTEM-ARCHITECTURE.md)
4. [03 — Hardware & Wiring](03-HARDWARE-AND-WIRING.md)
5. [04 — IoT Firmware](04-IOT-FIRMWARE.md)
6. [05 — Communication Protocol](05-COMMUNICATION-PROTOCOL.md)
7. [06 — Backend API](06-BACKEND-API.md)
8. [07 — Database Design](07-DATABASE-DESIGN.md)
9. [08 — Flutter App](08-FLUTTER-APP.md)
10. [09 — Business Logic](09-BUSINESS-LOGIC.md)
11. [10 — Notifications](10-NOTIFICATIONS.md)
12. [11 — Security](11-SECURITY.md)
13. [12 — Deployment](12-DEPLOYMENT.md)
14. [13 — Testing Strategy](13-TESTING.md)
15. [14 — Roadmap](14-ROADMAP.md)
16. [15 — Branding](15-BRANDING.md)
17. [17 — Migrasi Supabase-only](17-SUPABASE-MIGRATION.md) ← **sumber kebenaran Fase 8**
18. [Cetak Biru Mesin Pengaduk](CetakBiru/README.md)

## Ringkasan Keputusan
- Client: **Flutter** (Android + Web sekarang; desktop/iOS nanti).
- Backend: **Supabase** (Postgres + Edge Functions + Cron). Bun/Elysia + MySQL
  lama diarsipkan (lihat Fase 8).
- IoT transport: **HTTP REST** (mudah disimulasikan, LAN/domain).
- Data: live value realtime; **histori tersampling per interval (default 15
  menit, dapat diatur)**; opsi simpan raw untuk analitik.
- User: **single user tanpa login** (Supabase `anon key`, RLS read-only).
- Heater: **otomatis + safety cutoff + override app**.
- Katup solenoid: **manual dari aplikasi** (tidak otomatis saat matang).
- Heater: **otomatis + safety cutoff + override app**.
- Katup solenoid: **manual dari aplikasi** (tidak otomatis saat matang).

## Arsip Proyek Lama
Materi proyek lama (mockup Android + firmware ultrasonik) yang **sudah tidak
dipakai** ada di [`reference/legacy/`](reference/legacy/README.md).
