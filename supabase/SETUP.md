# Panduan Setup Supabase SIMOHE (klik-per-klik)

Dari nol sampai backend jalan. Butuh: akun Supabase (Free tier cukup),
`device_key` 32 char acak untuk ESP, dan repo ini.

## 0. Siapkan device key

```bash
# 32 char hex acak (simpan baik-baik, hanya tampil sekali di sini)
openssl rand -hex 16
echo -n '<PASTE_HASIL_DI_ATAS>' | sha256sum   # -> 64 hex untuk seed.sql
```

## 1. Buat project

1. https://supabase.com/dashboard → **New project**.
2. Name `simohe`, region **Singapore** (atau terdekat), password DB kuat.
3. Tunggu provisioning. Catat dari **Project Settings → API**:
   - `Project URL` → `https://<ref>.supabase.co`
   - `Publishable key` (`sb_publishable_...`; proyek lama: `anon key`).

## 2. Migrasi skema + RLS

Dashboard → **SQL Editor → New query**, jalankan berurutan:

1. Isi `supabase/migrations/0001_init.sql` → **Run**.
2. Isi `supabase/migrations/0002_events_read.sql` → **Run**.
3. Verifikasi: **Table Editor** menampilkan 8 tabel
   (`devices`, `latest_state`, `telemetry_raw`, `sensor_readings`,
   `settings`, `commands`, `events`, `batches`).

## 3. Seed

1. Di `supabase/seed.sql`, ganti `DEVICE_KEY_HASH_HEX` dengan 64 hex dari
   langkah 0.
2. Jalankan di SQL Editor. Cek `devices` berisi 1 baris.

## 4. Secrets Edge Functions

Dashboard → **Edge Functions → Secrets** (atau `supabase secrets set`):

| Secret | Nilai |
|---|---|
| `SUPABASE_URL` | Project URL (biasanya otomatis tersedia) |
| `SUPABASE_SERVICE_ROLE_KEY` | Service role key (JANGAN ke repo/app) |
| `APP_WRITE_KEY` | (opsional, disarankan) string acak untuk header `X-App-Key` |

## 5. Deploy functions

Via CLI (butuh `supabase` CLI + access token):

```bash
supabase link --project-ref <ref>
supabase functions deploy iot-ingest app-command app-settings app-batch jobs-tick
```

Atau Dashboard → **Edge Functions → New Function**, paste tiap
`supabase/functions/*/index.ts` beserta `supabase/functions/_shared/`.

## 6. Cron jobs-tick

1. Aktifkan ekstensi **pg_cron** + **pg_net**:
   Dashboard → **Database → Extensions** → enable keduanya.
2. Di `supabase/cron.sql`, ganti `<PROJECT_REF>`, `<SUPABASE_ANON_KEY>`
   (isi publishable key), `<APP_WRITE_KEY_JIKA_DISET>` (hapus baris header
   bila tidak diset), lalu jalankan di SQL Editor.
3. Cek: `select * from cron.job;` → ada `simohe-jobs-tick` tiap menit.

## 7. Uji backend (tanpa hardware)

```bash
export SUPABASE_URL=https://<ref>.supabase.co
export SUPABASE_ANON_KEY=<publishable-key>
export DEVICE_KEY=<32-char-plaintext>

# ingest normal + ack otomatis
./supabase/tools/sim-curl.sh normal 5 2

# skenario lain
./supabase/tools/sim-curl.sh mature 5 2
./supabase/tools/sim-curl.sh overheat 3 2
./supabase/tools/sim-curl.sh offline 40     # picu device_offline, lalu online lagi
./supabase/tools/sim-curl.sh safety          # event SAFETY_CUTOFF dari perangkat

# tulis via functions (ganti <id-command> setelah create)
curl -s -X POST "$SUPABASE_URL/functions/v1/app-command" \
  -H "apikey: $SUPABASE_ANON_KEY" -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
  -H 'Content-Type: application/json' \
  -d '{"action":"valve_open"}'
```

Lalu verifikasi di **Table Editor**: `latest_state` terisi, `events`
bertambah, `commands` `pending→sent→acked` setelah ingest berikutnya,
`sensor_readings` terisi tiap `history_interval_min` (via cron).

## 8. Aplikasi

```bash
flutter run -d chrome \
  --dart-define=SUPABASE_URL=https://<ref>.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=<publishable-key> \
  --dart-define=APP_WRITE_KEY=<sama-dengan-secret-bila-diset>
```

APK/Web rilis: `flutter build apk` / `flutter build web` dengan
`--dart-define` yang sama.

## 9. Firmware ESP

1. Salin `firmware/esp8266/simohe_esp/src/secrets.example.h` → `secrets.h`.
2. Isi `SIMOHE_BASE_URL=https://<ref>.supabase.co`,
   `SIMOHE_ANON_KEY=<publishable-key>`, `SIMOHE_DEVICE_KEY=<32-char>`.
3. Flash: `pio run -e esp -t upload`.

## 10. Operasional

- Backup: Dashboard → **Database → Backups** (jadwal harian; Free tier
  retensi terbatas — ekspor berkala via SQL Editor bila perlu).
- Log functions: Dashboard → **Edge Functions → Logs**.
- Rotasi device key: update `devices.device_key` (hash baru) + `secrets.h`
  ESP + flash ulang.
