# 08 — Flutter App

## Tujuan
Satu basis kode untuk **Android** dan **Web** (desktop/iOS menyusul). Aplikasi
responsif, dengan fokus monitoring + kontrol yang jelas.

## Stack & Paket (rencana)
| Kebutuhan | Paket |
|---|---|
| State management | `flutter_riverpod` |
| Routing | `go_router` |
| HTTP | `dio` |
| Model & serialisasi | `freezed` + `json_serializable` |
| Chart | `fl_chart` |
| Format waktu/angka | `intl` |
| Penyimpanan lokal | `shared_preferences` (cache) |
| Notifikasi lokal | `flutter_local_notifications` (opsional) |
| Env | `--dart-define` (mis. `API_BASE_URL`) |

> Tambahkan paket hanya saat fase terkait dimulai; jaga `pubspec.yaml` tetap
> ramping. Lihat `AGENTS.md` untuk aturan menambah dependensi.

## Struktur `lib/`
```
lib/
├── main.dart
├── app.dart                       # MaterialApp + tema + router
├── core/
│   ├── config/app_config.dart     # API_BASE_URL, interval polling
│   ├── constants/app_constants.dart
│   ├── theme/app_theme.dart
│   ├── network/api_client.dart    # Dio + interceptor token + error mapping
│   ├── router/app_router.dart     # go_router + shell (bottom nav/rail)
│   └── utils/                     # formatter, ekstensi
├── features/
│   ├── dashboard/                 # nilai live + status + kontrol cepat
│   ├── history/                   # grafik + ringkasan + ekspor
│   ├── control/                   # katup & heater
│   ├── notifications/             # daftar event
│   ├── settings/                  # ambang & interval
│   └── device/                    # info & status koneksi
└── shared/
    ├── models/                    # model domain (freezed)
    └── widgets/                   # kartu, badge status, chart wrapper
```

Setiap fitur mengikuti pola:
```
features/<nama>/
├── data/         # repository + datasource (panggil ApiClient)
├── domain/       # model + provider state
└── presentation/  # screen + widget
```

## State Management (Riverpod)
- `Provider` untuk dependensi (ApiClient, repository).
- `AsyncNotifierProvider` untuk data async (live, readings, events, settings).
- `Timer.periodic` di dalam notifier untuk polling; dibatalkan saat dispose.
- Provider turunan untuk agregasi (mis. status kematangan → warna badge).

## Routing (go_router)
- Shell dengan navigasi adaptif:
  - Lebar < 700 px → **NavigationBar** (bawah), 5 tab.
  - Lebar ≥ 700 px → **NavigationRail** (samping).
- Rute: `/dashboard`, `/history`, `/control`, `/notifications`, `/settings`,
  `/device`.
- Deep link web didukung.

## Layar

### 1. Dashboard
- Kartu **Suhu** (nilai, status normal/dingin/panas).
- Kartu **NH3** (nilai, ambang, indikator kematangan).
- Badge status pupuk: `fermenting` / `mature` / `draining`.
- Status perangkat (online/offline, `last_seen`).
- Status heater & katup + tombol kontrol cepat.
- Mini chart tren 24 jam.

### 2. History
- Pemilih rentang: 24 jam / 7 hari / 30 hari.
- Grafik garis **suhu** dan **NH3** (fl_chart), bisa dua seri.
- Ringkasan min/max/rata-rata.
- Tabel data + ekspor CSV (terutama di web).

### 3. Control
- **Katup**: tombol Buka/Tutup dengan dialog konfirmasi + info safety
  (`valve_max_open_min`), status perintah (pending/sent/acked).
- **Heater**: switch mode AUTO / FORCE ON (dengan durasi) / FORCE OFF,
  menampilkan status safety.

### 4. Notifications
- Daftar event, filter belum dibaca, badge jumlah.
- Tandai dibaca / tandai semua.
- Notifikasi "matang" diberi penekanan khusus.

### 5. Settings
- Interval sampling (15 menit default), interval ingest.
- Ambang suhu min/max & hysteresis.
- Ambang NH3 matang & durasi tahan.
- Mode heater & batas safety.
- Base URL server (untuk dev).
- Info device & versi firmware.

## Desain UI
- Material 3, seed hijau (pertanian).
- Warna status: normal=hijau, peringatan=oranye, bahaya=merah, offline=abu.
- Komponen bersama: `StatusBadge`, `MetricCard`, `TrendChart`, `SectionCard`.
- Aksesibilitas: kontras cukup, target sentuh ≥ 48dp, dukung teks besar.

## Model Domain (ringkas)
```dart
class LiveState {
  final DeviceInfo device;
  final SensorState state;
  final MaturityInfo maturity;
}
class SensorState {
  final double? tempC;
  final double? nh3Ppm;
  final bool heaterOn;
  final bool valveOpen;
  final String mode;
  final String status;
  final DateTime updatedAt;
}
class ReadingPoint {
  final DateTime ts;
  final double? tempC;
  final double? nh3Ppm;
  final bool heaterOn;
  final bool valveOpen;
}
class EventItem {
  final int id;
  final String type;
  final String severity;
  final String message;
  final bool isRead;
  final DateTime createdAt;
}
```

## Alur Network
1. `ApiClient` menyisipkan `Authorization: Bearer <APP_TOKEN>`.
2. Error mapping: 401 → pesan token; 5xx → retry/indikator; timeout → status
   offline.
3. Cache lokal untuk menampilkan data terakhir saat offline.

## Web vs Android
- **Android**: notifikasi lokal via `flutter_local_notifications`; akses network
  jelas (INTERNET permission).
- **Web**: tanpa notifikasi lokal native (gunakan notifikasi browser sebagai
  opsi); ekspor CSV lewat unduhan; responsif desktop.
- Hindari API khusus platform tanpa guard (`kIsWeb`).

## Konfigurasi Build
```bash
# Android
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:3000 --dart-define=APP_TOKEN=change-me-app-token

# Web
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3000 --dart-define=APP_TOKEN=change-me-app-token
```

## Catatan Implementasi (Fase 3)
- Paket aktual: `flutter_riverpod`, `go_router`, `dio`, `freezed` +
  `json_serializable` (codegen `build_runner`), `fl_chart`, `intl`,
  `shared_preferences`, dan `web` (khusus ekspor CSV).
- Autentikasi: `ApiClient` menyisipkan `Authorization: Bearer <APP_TOKEN>`.
  `API_BASE_URL` dan `APP_TOKEN` diisi lewat `--dart-define` (lihat di atas).
- Routing: 5 tab dalam shell adaptif (`NavigationBar` < 700 px,
  `NavigationRail` ≥ 700 px). `/device` adalah rute penuh di luar shell.
- Model `freezed` memetakan langsung kontrak `docs/06` (snake_case lewat
  `@JsonKey`, enum lewat `@JsonValue`); file `.freezed.dart`/`.g.dart`
  di-generate dan ikut di-commit.
- Polling live tiap 10 detik dan events tiap 30 detik via `Timer.periodic`
  di dalam notifier Riverpod; timer dibatalkan saat provider dispose.
- Cache offline hanya untuk nilai `live` (`shared_preferences`), dipakai bila
  request gagal karena jaringan.
- Ekspor CSV memakai `package:web` di web dan melempar `UnsupportedError` di
  platform non-web.
- Notifikasi lokal (`flutter_local_notifications`) **ditunda** (lihat backlog);
  notifikasi in-app (badge jumlah + daftar event) sudah tersedia.

