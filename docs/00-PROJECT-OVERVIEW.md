# 00 — Project Overview

## Nama
**SIMOHE** — Sistem Monitoring Pengolahan Kotoran Hewan berbasis IoT.

> Catatan: "SIMOHE" adalah singkatan dari *Sistem Monitoring Pengolahan Kotoran
> Hewan*. Tagline: *Sistem Monitoring Pengolahan Kotoran Hewan*.

## Latar Belakang
Sistem lama (`Monitoring KOHE`) adalah mockup Android (Kotlin/XML) dengan nilai
sensor acak dan firmware ultrasonik. Sistem itu tidak memiliki server, tidak
terhubung perangkat nyata, dan tidak punya histori/diagram. Proyek ini adalah
**rebuild total** menjadi sistem IoT end-to-end yang layak dan lengkap.

## Tujuan
Membangun sistem monitoring pengolahan kotoran hewan yang:
1. Memantau **suhu air** dan **kadar gas amonia (NH3)** secara berkala.
2. Menentukan **status kematangan pupuk** berdasarkan ambang amonia yang
   dapat dikonfigurasi.
3. Memberi **notifikasi** saat pupuk matang — **tanpa** membuka katup otomatis.
4. Mengontrol **heater** otomatis (dengan safety cutoff) dan dapat di-override
   dari aplikasi.
5. Membuka **katup solenoid** hanya melalui perintah manual dari aplikasi.
6. Menyimpan **histori** sensor dengan interval yang dapat diatur (default 15
   menit) dan menampilkannya dalam **diagram/chart**.
7. Berjalan lintas platform: **Android** dan **Web** (desktop/iOS menyusul).

## Ruang Lingkup
Termasuk:
- Aplikasi Flutter (Android + Web).
- Server Bun + TypeScript + Elysia.
- Database MySQL.
- Firmware Arduino Mega 2560 + ESP8266.
- Dokumentasi desain, pengujian, dan deployment.

Tidak termasuk (untuk sekarang):
- Login/multi-user (single user tanpa login).
- Aplikasi desktop & iOS (dapat ditambahkan kemudian).
- Push notification lintas platform (FCM) — direncanakan sebagai opsi lanjutan.
- Kontrol otomatis katup (tetap manual by design).

## Glosarium
| Istilah | Arti |
|---|---|
| **Pupuk matang** | Pupuk yang kadar gas amonianya sudah melewati ambang matang secara stabil |
| **Kadar amonia (NH3)** | Konsentrasi gas amonia dalam ppm, dibaca sensor MQ-137 |
| **Suhu air** | Suhu cairan/pupuk, dibaca DS18B20 |
| **Heater** | Pemanas untuk menjaga suhu fermentasi |
| **Katup solenoid** | Valve pembuangan, hanya dibuka manual dari aplikasi |
| **Ingest** | Pengiriman data dari perangkat IoT ke server |
| **Live value** | Nilai sensor terbaru (realtime, tidak disimpan permanen) |
| **Sampling** | Penyalinan live value ke histori tiap interval (default 15 menit) |
| **Batch/siklus** | Satu periode fermentasi dari mulai sampai dipanen |

## Dokumentasi Terkait
- `01-REQUIREMENTS.md` — kebutuhan sistem
- `02-SYSTEM-ARCHITECTURE.md` — arsitektur & diagram
- `03-HARDWARE-AND-WIRING.md` — perangkat keras & wiring
- `04-IOT-FIRMWARE.md` — desain firmware
- `05-COMMUNICATION-PROTOCOL.md` — protokol komunikasi
- `06-BACKEND-API.md` — API server
- `07-DATABASE-DESIGN.md` — desain database
- `08-FLUTTER-APP.md` — desain aplikasi Flutter
- `09-BUSINESS-LOGIC.md` — logika kematangan, suhu, katup
- `10-NOTIFICATIONS.md` — notifikasi
- `11-SECURITY.md` — keamanan
- `12-DEPLOYMENT.md` — deployment
- `13-TESTING.md` — strategi pengujian
- `14-ROADMAP.md` — peta jalan
