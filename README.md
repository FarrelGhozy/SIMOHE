# SIMOHE — Sistem Monitoring Pengolahan Kotoran Hewan (IoT)

Sistem monitoring pengolahan kotoran hewan berbasis IoT: memantau **suhu air**
dan **kadar gas amonia (NH3)**, mendeteksi **kematangan pupuk** dan memberi
**notifikasi**, serta mengontrol **heater** (otomatis) dan **katup solenoid**
(manual dari aplikasi).

> Proyek ini adalah **rebuild total** dari mockup Android lama "Monitoring KOHE".
> Materi lama diarsipkan di `docs/reference/legacy/` (tidak dipakai).

## Fitur
- Monitoring suhu air (DS18B20) & gas amonia (MQ-137) secara berkala.
- Deteksi kematangan pupuk berbasis ambang NH3 (dapat dikonfigurasi) + notifikasi.
- Heater otomatis dengan safety cutoff & override dari aplikasi.
- Katup solenoid **hanya** dibuka manual dari aplikasi.
- Histori sensor tersampling (default 15 menit, dapat diatur) & grafik.
- Notifikasi (matang, suhu tidak normal, device offline, safety cutoff).
- Aplikasi Flutter untuk **Android** & **Web**.

## Arsitektur
```
Perangkat IoT (Arduino Mega + ESP8266)
        │  HTTP POST /api/iot/ingest
        ▼
Server (Bun + TypeScript + Elysia)
        │  SQL
        ▼
MySQL
        ▲
        │  HTTP REST (polling)
Aplikasi Flutter (Android + Web)
```

## Struktur Repo
```
SIMOHE/
├── lib/                  # kode aplikasi Flutter
├── android/ web/         # platform Flutter
├── docs/                 # SELURUH rancangan (sumber kebenaran desain)
│   └── reference/legacy/ # arsip proyek lama (jangan dipakai)
├── server/               # backend Bun + Elysia (rencana)
├── firmware/             # firmware Mega + ESP8266 (rencana)
├── AGENTS.md             # panduan kerja
├── TODO.md               # fase & checklist
└── pubspec.yaml
```

## Hardware
- Arduino Mega 2560 R3 + ESP8266 WiFi (board built-in IoT).
- Sensor suhu air DS18B20 (waterproof).
- Sensor gas amonia MQ-137.
- 2-channel relay: K1 = katup solenoid, K2 = heater.
- Catu daya 12V + step-down 5V.

Detail: `docs/03-HARDWARE-AND-WIRING.md`.

## Menjalankan Aplikasi (Flutter)
```bash
flutter pub get
flutter analyze
flutter test
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3000
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:3000   # Android
```

## Dokumentasi
Mulai dari [`docs/README.md`](docs/README.md) dan
[`docs/00-PROJECT-OVERVIEW.md`](docs/00-PROJECT-OVERVIEW.md).
Checklist pengerjaan: [`TODO.md`](TODO.md). Aturan kerja: [`AGENTS.md`](AGENTS.md).

## Status
Fase 0 (fondasi & dokumentasi) selesai. Berikutnya: Fase 1 — backend inti.
Lihat `TODO.md` untuk daftar lengkap.
# SIMOHE
