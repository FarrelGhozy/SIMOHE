# 08 — Flutter App

> **Migrasi 2026-10-14 (Fase 8)**: `ApiClient` Dio + `API_BASE_URL`/`APP_TOKEN`
> diganti **`supabase_flutter`** (`SUPABASE_URL`/`SUPABASE_PUBLISHABLE_KEY`,
> tanpa login). Baca langsung PostgREST, tulis via Edge Functions, Realtime
> dengan fallback polling. Bagian yang masih menyebut Dio/APP_TOKEN di bawah
> adalah arsip pra-migrasi.

## Tujuan
Satu basis kode untuk **Android** dan **Web** (desktop/iOS menyusul). Aplikasi
responsif, dengan fokus monitoring + kontrol yang jelas.

## Stack & Paket (aktif)
| Kebutuhan | Paket |
|---|---|
| State management | `flutter_riverpod` |
| Routing | `go_router` |
| Backend | `supabase_flutter` (PostgREST + Functions + Realtime) |
| Model & serialisasi | `freezed` + `json_serializable` |
| Chart | `fl_chart` |
| Format waktu/angka | `intl` |
| Penyimpanan lokal | `shared_preferences` (cache) |
| Notifikasi lokal | `flutter_local_notifications` (opsional) |
| Env | `--dart-define` (`SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`) |

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
- Rute shell: `/dashboard`, `/history`, `/control`, `/analysis`,
  `/settings`. Tab **Analisis** (ikon tabung `science_outlined`)
  menggantikan tab Notifikasi.
- `/notifications` adalah rute penuh di luar shell (seperti `/device`),
  dibuka lewat ikon lonceng di AppBar semua tab utama. Tap item tetap
  membuka bottom sheet detail. Deep link web didukung.

## Layar

### 1. Dashboard
- Kartu **Suhu** (nilai, status normal/dingin/panas).
- Kartu **NH3** (nilai, ambang, indikator kematangan).
- Badge status pupuk: `fermenting` / `mature` / `draining`.
- Status perangkat (online/offline, `last_seen`).
- Status heater & katup + tombol kontrol cepat.
- Mini chart tren 24 jam — ikut polling + Realtime `sensor_readings`, dan
  tombol/pull-to-refresh dashboard menyegarkan angka live **dan** tren
  sekaligus. Titik dicatat tiap `history_interval_min` (default 15 mnt)
  sehingga gerak grafik lebih lambat dari angka live (lihat catatan di kartu).

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

### 4. Analisis (pengganti tab Notifikasi)
- % **stabilitas gelombang NH3** ("tabung makin pipih = makin stabil")
  sebagai indikator kematangan, dihitung full di HP dari `telemetry_raw`
  dalam window (fallback `sensor_readings`): `lib/features/analysis/`.
- Pengaturan lokal: window (15/30/60/120 mnt), ambang matang % (50–98),
  toleransi tabung ppm, cek otomatis. Rumus: `0.65*skorRange + 0.35*skorStd`.
- Fail-safe: nilai nol / banyak null / data identik persis / perangkat
  offline / sensor error → TIDAK dinilai matang, TIDAK ada notifikasi.
- Notifikasi lokal sekali per periode stabil (re-arm bila % turun 5 poin).
- Rekapan ringkas tampil di Dashboard (`StabilityRecap`).
- Katup tetap manual — matang tidak pernah membuka katup otomatis.

### 5. Notifications (lewat lonceng top bar)
- TIDAK lagi tab utama. Widget bersama `NotificationBell`
  (`shared/widgets/notification_bell.dart`, badge unread) dipasang di
  AppBar Dashboard, Riwayat, Kontrol, Analisis, Pengaturan; ketuk →
  `push('/notifications')` (rute root, ada tombol kembali).
- Daftar event, filter belum dibaca (tersimpan lokal), badge jumlah.
- Tap event membuka **bottom sheet detail**: ikon, jenis, severity, pesan,
  waktu, `payload` ringkas, status dibaca, dan tombol aksi kontekstual
  (mis. `mature` → Kontrol, offline → Perangkat).
- Menandai dibaca bersifat optimistik (dot hilang seketika) + umpan balik
  "Ditandai dibaca"; "Tandai semua" memakai dialog konfirmasi + SnackBar.
- **Notifikasi sistem lokal** (Android) via `flutter_local_notifications`:
  event baru (`id` > `notif.last_seen_event_id`) memunculkan notifikasi tray.
  Tap notifikasi membuka `/notifications?id=<id>` lalu sheet detail.
  Hanya saat aplikasi berjalan (FCM untuk app tertutup = backlog).

### 6. Settings
- **Aplikasi — ambil data** (lokal, `shared_preferences`): interval Live
  (5/10/15/30 dtk), Notifikasi (15/30/60/120 dtk), Status perintah
  (3/5/10/15 dtk), Tren dashboard (30/60/120/300/900 dtk). Mengatur frekuensi
  polling app; berbeda dari "Interval" server di bawah.
- **Notifikasi** (lokal): aktif/nonaktif notifikasi sistem + opsi hanya
  peringatan & bahaya ke atas.
- Interval sampling (15 menit default), interval ingest (server/device).
- Ambang suhu min/max & hysteresis.
- Ambang NH3 matang & durasi tahan.
- Mode heater & batas safety.
- Base URL server (untuk dev).
- Info device & versi firmware.

## Desain UI
- Material 3, seed hijau (pertanian).
- Warna status: normal=hijau, peringatan=oranye, bahaya=merah, offline=abu.
- Komponen bersama: `StatusBadge`, `MetricCard`, `TrendChart`, `SectionCard`,
  `AppSegmented`.
- Segmented control (`AppSegmented`, dipakai untuk mode heater dan rentang
  riwayat) selalu `showSelectedIcon: false` — tanpa ikon ceklis; status
  terpilih hanya ditandai warna background/foreground tema agar lebar segmen
  stabil.
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

## Alur Network (aktif, Supabase)
1. `Supabase.initialize(url, publishableKey)` di `main()`; klien via
   `supabaseClientProvider`.
2. Repository `DeviceScopedRepository`: resolve device aktif (id terkecil)
   sekali lalu cache; semua query filter `device_id`.
3. Baca via PostgREST (`devices`, `latest_state`, `settings`, `events`,
   `commands`, `sensor_readings`/`telemetry_raw`, `batches`); tulis via
   `functions.invoke('app-command'|'app-settings'|'app-batch')`.
4. Realtime subscribe (`latest_state`, `sensor_readings`, `events`,
   `commands`) + polling (interval dari Pengaturan Aplikasi, default
   10/30/5/60 dtk) sebagai fallback; error → `ApiException.fromSupabase`.
5. Cache lokal nilai `live` untuk mode offline.
6. Agregasi `1h` dan ringkasan dihitung di klien dari data `15m`.
7. Notifikasi sistem lokal (Android) membandingkan `id` event baru terhadap
   `notif.last_seen_event_id` (shared_preferences) agar tidak dobel.

## Web vs Android
- **Android**: notifikasi lokal via `flutter_local_notifications`; akses network
  jelas (INTERNET permission).
- **Web**: tanpa notifikasi lokal native (gunakan notifikasi browser sebagai
  opsi); ekspor CSV lewat unduhan; responsif desktop.
- Hindari API khusus platform tanpa guard (`kIsWeb`).

## Konfigurasi Build
```bash
# Android & Web (tanpa login)
flutter run --dart-define=SUPABASE_URL=https://<ref>.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=<publishable> \
  [--dart-define=APP_WRITE_KEY=<bila-diset>]
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
- Polling live (default 10 dtk), tren dashboard (default 60 dtk), events
  (default 30 dtk), dan status perintah (default 5 dtk) via `Timer.periodic`
  di dalam notifier Riverpod; interval dapat diubah dari Pengaturan →
  Aplikasi (lokal, `shared_preferences`), timer di-restart lewat
  `ref.listen(refreshSettingsProvider)`. Timer dibatalkan saat provider
  dispose.
- Cache offline hanya untuk nilai `live` (`shared_preferences`), dipakai bila
  request gagal karena jaringan.
- Ekspor CSV memakai `package:web` di web dan melempar `UnsupportedError` di
  platform non-web.
- Notifikasi lokal sistem (`flutter_local_notifications`, Android) dipakai
  untuk event baru saat aplikasi berjalan; permission `POST_NOTIFICATIONS`
  diminta saat init. Web memakai badge + daftar in-app (notifikasi sistem web
  belum diaktifkan). FCM untuk app tertutup tetap di backlog.
- Preferensi lokal (interval refresh, notifikasi, filter belum dibaca)
  disimpan di `shared_preferences` (`prefs.*`); cache offline `live` tetap
  `cache.live_state`.

## Aset & Branding
- Aset brand: `assets/branding/emblem.png` dan `logo_monochrome.png`. Nama aset
  dipusatkan di `core/theme/brand_colors.dart` (`BrandAssets`).
- Tema memakai seed hijau brand `#084E34`; palet lengkap di `docs/15-BRANDING.md`.
- Ikon fitur dipakai dari **Material Icons** bawaan, bukan ikon ilustrasi.
- Widget `BrandIcon` menampilkan emblem (dengan fallback ikon Material).
- Ikon aplikasi (Android + web) di-generate via `flutter_launcher_icons`
  (`dart run flutter_launcher_icons`); splash Android + web via
  `flutter_native_splash` (`dart run flutter_native_splash:create`,
  `web: true`): latar hijau tua brand `#084E34` + logo komposit
  `assets/branding/splash_logo.png` (emblem putih + teks SIMOHE +
  tagline "Sistem Monitoring Pengolahan Kotoran Hewan (IoT)").
- Sumber ikon launcher/splash ada di `branding/` (tidak ikut di-ship ke bundle).

