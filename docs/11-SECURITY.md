# 11 — Security

## Prinsip
- **Least privilege**: setiap komponen hanya bisa melakukan yang diperlukan.
- **Fail-safe**: saat ragu/gagal, aktuator kembali ke kondisi aman (heater OFF,
  katup tertutup).
- **Tanpa rahasia di repo**: semua kredensial via environment.
- **Anggap jaringan tidak tepercaya** untuk produksi (selalu HTTPS).

## Autentikasi & Otorisasi
| Aktor | Mekanisme |
|---|---|
| Perangkat IoT | Header `X-Device-Key` (32 char acak per device) |
| Aplikasi (single user) | Header `Authorization: Bearer <APP_TOKEN>` |
| Admin DB | User MySQL khusus, hak terbatas pada database aplikasi |

- `device_key` dan `APP_TOKEN` dibuat acak (mis. 32+ byte dari CSPRNG).
- Kunci tersimpan sebagai hash? Untuk MVP, perbandingan langsung dapat diterima
  karena single-device & di belakang TLS; namun disarankan simpan **hash**
  (mis. SHA-256) dan bandingkan hash.
- Rotasi: sediakan prosedur ganti `device_key`/`APP_TOKEN` di `.env` + update
  ESP.

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
- MySQL **tidak** diekspos ke publik (hanya jaringan internal Docker).
- User aplikasi bukan `root`; hak hanya SELECT/INSERT/UPDATE/DELETE pada DB app.
- Backup terjadwal (lihat `12-DEPLOYMENT.md`).
- `utf8mb4`, koneksi internal.

## Aplikasi Flutter
- Jangan hardcode token di kode; gunakan `--dart-define`.
- Untuk web, sadari token bisa terlihat di klien (single user). Batasi origin
  server (CORS) dan gunakan HTTPS.
- Validasi/kuras input (meski server tetap validasi).
- Sembunyikan data sensitif di log.

## Firmware
- Simpan kredensial WiFi & device key di konfigurasi, bukan di repo publik.
- Watchdog agar tidak hang.
- Fail-safe saat sensor gagal / koneksi hilang.
- Batas safety keras (heater max on, suhu max, katup max open) tidak dapat
  dimatikan dari aplikasi.

## CORS
- Izinkan hanya origin aplikasi web resmi (`APP_CORS_ORIGIN` di `.env`).
- Untuk dev lokal boleh `*` sementara, jangan di produksi.

## Checklist Keamanan Rilis
- [ ] HTTPS aktif, HTTP dialihkan ke HTTPS
- [ ] `APP_TOKEN` & `device_key` kuat dan tidak ada di repo
- [ ] `.env` masuk `.gitignore`
- [ ] MySQL tidak terekspos publik
- [ ] Rate limit aktif
- [ ] CORS dibatasi
- [ ] User DB non-root
- [ ] Backup & retensi berjalan
- [ ] Log tidak memuat token
- [ ] Firmware fail-safe teruji
