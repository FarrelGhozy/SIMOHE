# 11 — Security

> **Migrasi 2026-10-14 (Fase 8)**: Bearer `APP_TOKEN` + MySQL dihapus. Akses
> via Supabase publishable key + RLS + Edge Functions (detail di `17`).

## Prinsip
- **Least privilege**: setiap komponen hanya bisa melakukan yang diperlukan.
- **Fail-safe**: saat ragu/gagal, aktuator kembali ke kondisi aman (heater OFF,
  katup tertutup).
- **Tanpa rahasia di repo**: semua kredensial via environment/dashboard secrets.
- **Anggap jaringan tidak terpercaya** untuk produksi (selalu HTTPS).

## Autentikasi & Otorisasi
| Aktor | Mekanisme |
|---|---|
| Perangkat IoT | Header `X-Device-Key` (32 char acak) + header Supabase `apikey` |
| Aplikasi (single user, tanpa login) | Publishable key + RLS read-only (`anon SELECT`) |
| Tulis aplikasi | Edge Functions (`service_role` internal) + opsional `X-App-Key` |
| Tandai notifikasi dibaca | UPDATE `is_read` langsung (trigger guard: kolom lain ditolak) |
| Admin DB | Dashboard Supabase (MFA aktif) |

- `device_key` dibuat acak; tersimpan sebagai **hash SHA-256** di
  `devices.device_key`.
- Publishable key memang publik — keamanannya dari RLS + validasi function.
- `service_role` hanya di Edge Functions Secrets, tidak pernah di repo/app.
- Rotasi: ganti `device_key` di DB + `secrets.h` + flash ulang; rotasi
  `APP_WRITE_KEY` bila dipakai.

## Transport
- **Produksi wajib HTTPS** (TLS via reverse proxy/Caddy).
- HTTP polos hanya untuk jaringan lokal saat pengembangan.
- Aplikasi web memanggil base URL HTTPS.
- ESP8266: gunakan `WiFiClientSecure` bila server HTTPS; sertakan CA fingerprint
  atau root cert (perhatikan keterbatasan RAM/sertifikat). Jika memungkinkan,
  gunakan TLS dengan fingerprint pinning.

## Validasi Input
- Validasi tipe & rentang di setiap endpoint (Elysia schema):
  - `temp_c`: -20..120
  - `nh3_ppm`: 0..1000
  - `action`: whitelist
  - `interval`: batas wajar (mis. sampling 1..1440 menit)
- Tolak payload tak dikenal/besar berlebihan (batas ukuran body).
- Jangan pernah memasukkan input pengguna langsung ke SQL → gunakan ORM
  (Drizzle) dengan parameter binding.

## Rate Limiting & Anti-Abuse
- Rate limit per `device_key` (mis. 1 req/detik) dan per app token.
- Batas body (mis. 16 KB) untuk ingest.
- `command` TTL mencegah eksekusi perintah basi.
- Opsional: nonce/`seq` + `ts` untuk mendeteksi replay; server menolak `seq`
  yang lebih kecil/duplikat dari yang terakhir bila diperlukan.

## Kesehatan API & Kesalahan
- Jangan bocorkan stack trace di produksi; kembalikan `{ error: { code, message } }`.
- Log akses tanpa data sensitif (jangan log token).

## Database
- Postgres milik Supabase (backup terjadwal di dashboard).
- RLS aktif di semua tabel; anon hanya SELECT (+ UPDATE `is_read` via trigger).
- Jangan ekspos `service_role` ke publik.
- Waktu tetap **UTC**.

## Aplikasi Flutter
- Jangan hardcode kunci di kode; gunakan `--dart-define`.
- Publishable key memang terlihat di klien (single user, RLS read-only).
- Validasi/kuras input (meski function tetap validasi).
- Sembunyikan data sensitif di log.

## Checklist Keamanan Rilis
- [ ] HTTPS (Supabase default), ESP menunjuk `https://<ref>.supabase.co`
- [ ] `device_key` kuat (32 char) dan hanya hash-nya di DB
- [ ] `service_role` hanya di Edge Functions Secrets
- [ ] RLS aktif + grant minimal (cek di SQL Editor)
- [ ] Rate limit ingest aktif (best-effort di function)
- [ ] Backup terjadwal + uji restore
- [ ] Log tidak memuat kunci
- [ ] Firmware fail-safe teruji

## Firmware
- Simpan kredensial WiFi & device key di konfigurasi, bukan di repo publik.
- Watchdog agar tidak hang.
- Fail-safe saat sensor gagal / koneksi hilang.
- Batas safety keras (heater max on, suhu max, katup max open) tidak dapat
  dimatikan dari aplikasi.

## CORS
- Supabase mengatur CORS untuk PostgREST/Functions; batasi URL aplikasi di
  **Dashboard → Authentication → URL Configuration** bila memakai Auth kelak.
- Tanpa login: tidak ada origin sensitif; keamanan dari RLS + validasi.

## Checklist Keamanan Rilis (lama, arsip — lihat checklist baru di atas)
- [ ] ~~HTTPS aktif, HTTP dialihkan ke HTTPS~~ → HTTPS default Supabase
- [ ] ~~`APP_TOKEN` & `device_key` kuat dan tidak ada di repo~~ → device_key + RLS
- [ ] ~~MySQL tidak terekspos publik~~ → Postgres milik Supabase
- [ ] ~~User DB non-root~~ → service_role hanya di Functions Secrets
