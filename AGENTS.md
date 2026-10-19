# AGENTS.md — Panduan Kerja SIMOHE

Panduan ini untuk siapa pun (manusia atau agent AI) yang mengerjakan repo ini.

## Apa Itu Proyek Ini
**SIMOHE** — Sistem Monitoring Pengolahan Kotoran Hewan berbasis IoT.
- **Sensor**: suhu air (DS18B20) & gas amonia (MQ-137).
- **Aktuator**: heater (otomatis + safety + override app) & katup solenoid
  (manual dari aplikasi).
- **Client**: Flutter (Android + Web).
- **Backend**: Supabase (Postgres + Edge Functions + Cron). Server Bun +
  TypeScript + Elysia lama **diarsipkan** ke `docs/reference/archive/server-bun-*/`
  (lihat `docs/17-SUPABASE-MIGRATION.md`, `TODO.md` Fase 8).
- **Database**: Postgres (Supabase, skema di `supabase/migrations/`).
- **Komunikasi IoT**: HTTPS REST (ESP8266 → Supabase Edge Function
  `/functions/v1/iot-ingest`).

Baca `docs/00-PROJECT-OVERVIEW.md` dan `docs/README.md` sebelum mulai.

## Keterangan Proyek Lama (Sebelum Rebuild)
Repo ini sebelumnya berisi proyek **"Monitoring KOHE"** versi mockup:
- Aplikasi Android native (Kotlin/XML) dengan **nilai sensor acak** (bukan nyata).
- Firmware ultrasonik yang membuka katup **otomatis** saat volume penuh.
- **Tidak ada** server, database, histori, maupun grafik.

Seluruh kode Android lama sudah **dihapus**. Materi lama diarsipkan di
`docs/reference/legacy/` (termasuk `IoT_KOHE/`) sebagai referensi historis saja.
**Jangan** memakai logika/konsep dari folder legacy dalam implementasi baru.

## Struktur Repo
```
SIMOHE/                     # root = proyek Flutter
├── lib/                    # kode Flutter (lihat docs/08)
│   ├── core/               # config, theme, network, router, utils
│   ├── features/           # dashboard, history, control, notifications, settings, device
│   └── shared/             # widget & model bersama
├── android/ web/           # platform Flutter (android + web)
├── docs/                   # SELURUH rancangan (sumber kebenaran desain)
│   ├── 17-SUPABASE-MIGRATION.md # sumber kebenaran Fase 8 (aktif)
│   └── reference/legacy/   # arsip proyek lama (jangan dipakai)
├── supabase/               # backend Supabase (functions + migrations + seed)
├── docs/reference/archive/server-bun-*/ # arsip server lama (jaga-jaga)
├── firmware/               # firmware Mega + ESP8266 (lihat docs/04)
├── AGENTS.md               # file ini
├── TODO.md                 # fase & checklist pengerjaan
└── pubspec.yaml
```

## Sumber Kebenaran (Docs)
Desain ada di `docs/`. Jika kode dan dokumen berbeda, **selaraskan** — jangan
biarkan menyimpang.
| Topik | File |
|---|---|
| Arsitektur | `docs/02-SYSTEM-ARCHITECTURE.md` |
| Hardware/wiring | `docs/03-HARDWARE-AND-WIRING.md` |
| Firmware | `docs/04-IOT-FIRMWARE.md` |
| Protokol | `docs/05-COMMUNICATION-PROTOCOL.md` |
| API | `docs/06-BACKEND-API.md` |
| Database | `docs/07-DATABASE-DESIGN.md` |
| Aplikasi | `docs/08-FLUTTER-APP.md` |
| Logika bisnis | `docs/09-BUSINESS-LOGIC.md` |
| Migrasi Supabase (aktif) | `docs/17-SUPABASE-MIGRATION.md` |
| Notifikasi | `docs/10-NOTIFICATIONS.md` |
| Keamanan | `docs/11-SECURITY.md` |
| Deployment | `docs/12-DEPLOYMENT.md` |
| Testing | `docs/13-TESTING.md` |
| Roadmap | `docs/14-ROADMAP.md` |
| Branding | `docs/15-BRANDING.md` |

## Perintah Umum

### Flutter (root)
```bash
flutter pub get
flutter analyze
flutter test
flutter run -d chrome --dart-define=SUPABASE_URL=https://<ref>.supabase.co --dart-define=SUPABASE_PUBLISHABLE_KEY=<publishable>
flutter run --dart-define=SUPABASE_URL=https://<ref>.supabase.co --dart-define=SUPABASE_PUBLISHABLE_KEY=<publishable>   # Android
flutter build apk
flutter build web
```

### Supabase (lihat docs/17, TODO Fase 8)
```bash
supabase link --project-ref <ref>
supabase db push
supabase functions deploy iot-ingest app-command app-settings app-batch jobs-tick
```

### Env lokal Supabase (`.env.local`, gitignored — jangan di-commit)
Semua kredensial cloud tersimpan di `.env.local` (root repo, `chmod 600`).
Muat dulu sebelum perintah Supabase/Flutter:
```bash
set -a; source .env.local; set +a
flutter run -d chrome --dart-define=SUPABASE_URL="$SUPABASE_URL" --dart-define=SUPABASE_PUBLISHABLE_KEY="$SUPABASE_PUBLISHABLE_KEY" --dart-define=APP_WRITE_KEY="$APP_WRITE_KEY"
SUPABASE_ACCESS_TOKEN="$SUPABASE_ACCESS_TOKEN" supabase link --project-ref "$SUPABASE_PROJECT_REF"
```
Isi: `SUPABASE_URL`, `SUPABASE_PROJECT_REF`, `SUPABASE_PUBLISHABLE_KEY`,
`DEVICE_KEY` (+ `DEVICE_KEY_HASH`), `APP_WRITE_KEY`, `SUPABASE_ACCESS_TOKEN`,
`SUPABASE_SERVICE_ROLE_KEY`. Token sensitif (access/service_role/device)
jangan pernah di-paste ke chat/log — tulis langsung ke file.

### Server lama (arsip, jangan dipakai)
```bash
# Kode ada di docs/reference/archive/server-bun-*/ hanya sebagai referensi porting.
# Butuh Bun? cd docs/reference/archive/server-bun-2026-10-14 && bun install
```

### Firmware
```bash
cd firmware/mega/simohe_mega && pio test -e native && pio run -e mega
cd firmware/esp8266/simohe_esp && pio test -e native && pio run -e esp
# flash ke hardware (Fase 6): pio run -e mega -t upload / pio run -e esp -t upload
```
Salin `firmware/esp8266/simohe_esp/src/secrets.example.h` → `secrets.h` lalu isi
kredensial (tidak di-commit). Bisa juga dibuka di Arduino IDE / PlatformIO.

## Konvensi Kode
- **Dart/Flutter**: ikuti `flutter_lints`; jalankan `flutter analyze` sebelum
  selesai. Struktur per fitur `data/domain/presentation`.
- **TypeScript/Bun**: `strict`; validasi input di boundary; format error
  seragam `{ error: { code, message } }`.
- **Jangan menumpuk kode besar dalam satu berkas**: pecah per tugas/domain.
  `index.ts` hanya merakit route; logika ke `service.ts`, skema ke `schema.ts`,
  mapper ke `response.ts`. Bila berkas membesar, pecah lagi jadi sub-berkas per
  tugas. Utilitas bersama ke `lib/`. Lihat `server/README.md` untuk detail.
- **Nama file Dart**: `snake_case.dart`; kelas `PascalCase`.
- **Tidak menambah komentar** yang menjelaskan hal obvious; dokumentasi desain
  ditulis di `docs/`, bukan tumpukan komentar.
- **UI**: Material 3, seed hijau, status warna (normal/peringatan/bahaya/offline).

## Aturan Penting (WAJIB)
1. **Rahasia tidak masuk repo**: token, kredensial DB, `device_key` → `.env`
   (lihat `.gitignore`). Sediakan `.env.example`. `service_role` hanya di
   Dashboard → Edge Functions → Secrets, tidak pernah di app/firmware/repo.
2. **Jangan commit** `.env`, `build/`, `.dart_tool/`, atau artefak build.
3. **Katup tidak boleh otomatis terbuka** saat pupuk matang — hanya manual dari
   aplikasi. Ini aturan desain keras.
4. **Safety selalu menang**: sensor gagal → heater OFF; suhu max / heater max on
   / katup max open → mati paksa. Tidak dapat dimatikan dari UI.
5. **Sinkronkan docs**: setiap keputusan desain baru → update file yang relevan
   di `docs/`. Jangan biarkan dokumen usang.
6. **Tambah dependensi secara sadar**: cek dulu apakah sudah ada di `pubspec.yaml`
   / `package.json`; hindari paket berlebihan. Catat alasan jika menambah.
7. **Anggap hardware belum ada**: gunakan **device simulator**
   (`supabase/tools/sim-curl.sh`) untuk menguji backend & aplikasi lebih dulu.
8. **Single user tanpa login**: kendali akses backend via Supabase `anon key` +
   RLS read-only + Edge Functions untuk tulis, bukan sistem akun.
9. **UTC** untuk semua waktu di server/DB.
10. Jangan menghapus folder `docs/reference/legacy/` (arsip).

## Alur Kerja yang Disarankan
1. Baca `TODO.md` untuk fase aktif.
2. Kerjakan item satu per satu; tandai status.
3. Jalankan analisis/test yang relevan.
4. Update dokumen jika ada penyimpangan desain.
5. Baru lanjut item berikutnya.

## Definition of Done
- Kode jelas, mengikuti konvensi, tanpa rahasia.
- `flutter analyze` bersih dan/atau test Edge Function lulus.
- Dokumen terkait diperbarui bila perlu.
- Checklist di `TODO.md` diperbarui.
