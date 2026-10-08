# Dokumentasi SIMOHE

Kumpulan dokumen rancangan (design) untuk rebuild proyek **SIMOHE** — Sistem
Monitoring Pengolahan Kotoran Hewan berbasis IoT (Flutter + Bun/Elysia + MySQL +
Arduino Mega & ESP8266).

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

## Ringkasan Keputusan
- Client: **Flutter** (Android + Web sekarang; desktop/iOS nanti).
- Backend: **Bun + TypeScript + Elysia**.
- Database: **MySQL**.
- IoT transport: **HTTP REST** (mudah disimulasikan, LAN/domain).
- Data: live value realtime; **histori tersampling per interval (default 15
  menit, dapat diatur)**; opsi simpan raw untuk analitik.
- User: **single user tanpa login** (Bearer token).
- Heater: **otomatis + safety cutoff + override app**.
- Katup solenoid: **manual dari aplikasi** (tidak otomatis saat matang).

## Arsip Proyek Lama
Materi proyek lama (mockup Android + firmware ultrasonik) yang **sudah tidak
dipakai** ada di [`reference/legacy/`](reference/legacy/README.md).
