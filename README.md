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

## Unduh Aplikasi (Release)
APK Android siap pakai (tidak perlu build sendiri) tersedia di halaman Release:

- **Rilis terbaru**: <https://github.com/FarrelGhozy/SIMOHE/releases/latest>
- **v1.0.2 langsung**: <https://github.com/FarrelGhozy/SIMOHE/releases/download/v1.0.2/app-release.apk>

Cara pasang di Android:
1. Unduh `app-release.apk` dari HP tujuan (atau salin filenya ke HP).
2. Buka file → bila diminta, aktifkan **"Install unknown apps / Sumber tidak dikenal"** untuk aplikasi pengelola file/browser.
3. Install → buka **SIMOHE**. Dashboard akan menampilkan perangkat yang sedang online.

> APK di-build dengan `--dart-define` (URL + key Supabase) tersemat di dalamnya,
> jadi langsung tersambung ke backend. Untuk membuat/memperbarui APK sendiri,
> lihat bagian [Menjalankan Aplikasi](#menjalankan-aplikasi-flutter).

## Arsitektur
```
Perangkat IoT (Arduino Mega + ESP8266)
        │  HTTPS POST /functions/v1/iot-ingest
        ▼
Supabase (Postgres + Edge Functions + Cron)
        ▲
        │  REST + Realtime
Aplikasi Flutter (Android + Web)
```
- Backend: **Supabase** (Postgres, Edge Functions, Cron). Server Bun lama
  diarsipkan di `docs/reference/archive/` — lihat `docs/17-SUPABASE-MIGRATION.md`.

## Struktur Repo
```
SIMOHE/
├── lib/                  # kode aplikasi Flutter
├── android/ web/         # platform Flutter
├── docs/                 # SELURUH rancangan (sumber kebenaran desain)
│   ├── reference/legacy/ # arsip proyek lama (jangan dipakai)
│   └── CetakBiru/        # blueprint fisik & rangka mesin
├── supabase/             # backend Supabase (functions + migrations + seed)
├── firmware/             # firmware Mega + ESP8266
├── AGENTS.md             # panduan kerja
├── TODO.md               # fase & checklist
└── pubspec.yaml
```

## Hardware
- Arduino Mega 2560 R3 + ESP8266 WiFi (board combo, mis. **RobotDyn MEGA+WiFi R3**).
- Sensor suhu air DS18B20 (waterproof) — Digital 2.
- Sensor gas amonia MQ-137 — Analog A0.
- 2-channel relay: K1 = katup solenoid (Digital 7), K2 = heater (Digital 6).
- Komunikasi Mega ↔ ESP lewat **Serial3 (TX 14 / RX 15)**, 115200 baud.
- Catu daya 12V + step-down 5V.

Detail wiring: [`docs/03-HARDWARE-AND-WIRING.md`](docs/03-HARDWARE-AND-WIRING.md).

## Firmware: Flash & Mode Mikrokontroler

Firmware dibangun dengan **PlatformIO** (tetap bisa dibuka di Arduino IDE).
Ada **dua** target: **Mega** (sensor/aktuator/logika) dan **ESP8266** (WiFi/HTTP).

### 1. Persiapan (untuk ESP)
Salin `firmware/esp8266/simohe_esp/src/secrets.example.h` → `secrets.h`, lalu isi:
```c
#define SIMOHE_WIFI_SSID     "nama-wifi-2.4GHz"
#define SIMOHE_WIFI_PASSWORD "kata-sandi"
#define SIMOHE_BASE_URL      "https://<ref>.supabase.co"
#define SIMOHE_ANON_KEY      "sb_publishable_..."
#define SIMOHE_DEVICE_KEY    "<device key>"
```
`secrets.h` sudah masuk `.gitignore` (jangan di-commit). ESP hanya mendukung
WiFi **2.4 GHz**.

> Penting: `SIMOHE_DEVICE_KEY` harus sama dengan kunci yang hash SHA-256-nya
> tersimpan di tabel `devices.device_key`. Kalau tidak cocok, server balas
> **401 UNAUTHORIZED** dan perangkat tidak akan pernah "online".

### 2. Uji logika (tanpa hardware)
```bash
cd firmware/mega/simohe_mega  && pio test -e native
cd firmware/esp8266/simohe_esp && pio test -e native
```

### 3. Compile & Flash
```bash
# Mega
cd firmware/mega/simohe_mega
pio run -e mega                 # kompilasi
pio run -e mega -t upload       # flash ke board

# ESP8266
cd firmware/esp8266/simohe_esp
pio run -e esp                  # kompilasi
pio run -e esp -t upload        # flash ke board

# bila ada >1 port serial, tentukan port eksplisit:
pio run -e esp -t upload --upload-port /dev/ttyUSB0   # Linux/macOS
pio run -e esp -t upload --upload-port COM5           # Windows
```
Baud serial monitor: **115200**.

### 4. Mode Mikrokontroler (DIP switch board combo)
Board combo RobotDyn MEGA+WiFi R3 memakai satu chip USB-serial (CH340) yang
diarahkan ke Mega atau ESP lewat **DIP switch 8-posisi** (switch 8 tidak dipakai):

| Mode | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|---|---|---|---|---|---|---|
| Upload ke **Mega2560** | OFF | OFF | ON | ON | OFF | OFF | OFF |
| Upload ke **ESP8266** | OFF | OFF | OFF | OFF | ON | ON | ON |
| Serial monitor ESP | OFF | OFF | OFF | OFF | ON | ON | OFF |
| **Jalan**: Mega ↔ ESP | ON | ON | ON | ON | OFF | OFF | OFF |
| Mega ↔ ESP (USB independen) | ON | ON | OFF | OFF | OFF | OFF | OFF |
| Semua terpisah | OFF | OFF | OFF | OFF | OFF | OFF | OFF |

Langkah praktis:
1. **Flash Mega**: set switch mode Mega (baris 1) → `pio run -e mega -t upload`.
2. **Flash ESP**: set switch mode ESP (baris 2); saat upload dimulai **tahan
   tombol `Mode`** di board; setelah selesai set **switch 7 = OFF**.
3. **Mode jalan** (operasi normal): set **switch 1–4 = ON** agar Mega ↔ ESP
   terhubung lewat Serial3. Ini mode yang dipakai saat perangkat beroperasi.

> Ringkasan: satu posisi DIP switch untuk "pilih mau flash Mega atau ESP",
> lalu posisi `1–4 ON` untuk "mode jalan". Detail ada di
> [`docs/03-HARDWARE-AND-WIRING.md` §6](docs/03-HARDWARE-AND-WIRING.md).

### 5. Verifikasi perangkat online
Kirim data dengan device simulator (tanpa hardware) atau cek status di aplikasi:
```bash
set -a; source .env.local; set +a
supabase/tools/sim-curl.sh normal 3 10    # 3 frame, jeda 10 detik
```
Kolom `is_online` / `last_seen_at` di tabel `devices` akan ter-update bila
perangkat benar-benar terkirim.

## Menjalankan Aplikasi (Flutter)
```bash
flutter pub get
flutter analyze
flutter test

# Web (butuh backend Supabase aktif)
set -a; source .env.local; set +a
flutter run -d chrome \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_PUBLISHABLE_KEY="$SUPABASE_PUBLISHABLE_KEY" \
  --dart-define=APP_WRITE_KEY="$APP_WRITE_KEY"

# Android (langsung ke HP via USB)
flutter run -d <device-id> \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_PUBLISHABLE_KEY="$SUPABASE_PUBLISHABLE_KEY" \
  --dart-define=APP_WRITE_KEY="$APP_WRITE_KEY"
```

### Build APK rilis sendiri
```bash
set -a; source .env.local; set +a
flutter build apk --release \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_PUBLISHABLE_KEY="$SUPABASE_PUBLISHABLE_KEY" \
  --dart-define=APP_WRITE_KEY="$APP_WRITE_KEY"
# hasil: build/app/outputs/flutter-apk/app-release.apk
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

> Catatan: build **release** butuh izin `android.permission.INTERNET` di
> `android/app/src/main/AndroidManifest.xml` (sudah diset di repo ini). Tanpa itu
> aplikasi release tidak dapat mengakses jaringan.

## Dokumentasi
Mulai dari [`docs/README.md`](docs/README.md) dan
[`docs/00-PROJECT-OVERVIEW.md`](docs/00-PROJECT-OVERVIEW.md).
Checklist pengerjaan: [`TODO.md`](TODO.md). Aturan kerja: [`AGENTS.md`](AGENTS.md).
Migrasi Supabase: [`docs/17-SUPABASE-MIGRATION.md`](docs/17-SUPABASE-MIGRATION.md).

## Status
Backend **Supabase-only** aktif; aplikasi Android/Web, firmware Mega + ESP8266,
dan migrasi database berjalan. Lihat `TODO.md` untuk daftar fase lengkap.
