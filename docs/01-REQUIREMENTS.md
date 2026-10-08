# 01 — Requirements

## Aktor
- **Operator (single user)** — memantau sensor, menerima notifikasi, mengontrol
  katup & heater dari aplikasi. Tidak ada login.
- **Perangkat IoT** — mengirim telemetry dan menerima perintah.
- **Server** — menyimpan data, mengevaluasi logika bisnis, menjembatani keduanya.

## Kebutuhan Fungsional

### FR-1 Ingest Telemetry
- Perangkat mengirim suhu air, kadar NH3, status heater, dan status katup ke
  server via HTTP POST pada interval yang dapat dikonfigurasi (default 10 detik).
- Server menyimpan nilai terbaru sebagai *live value*.

### FR-2 Sampling Histori
- Server menyalin live value ke tabel histori pada interval yang dapat diatur
  (default **15 menit**).
- Operator dapat mengubah interval dari aplikasi.

### FR-3 Monitoring
- Aplikasi menampilkan nilai suhu & NH3 terkini, status perangkat online/offline,
  status heater, dan status katup.
- Aplikasi menampilkan **grafik riwayat** suhu & NH3 (rentang 24 jam / 7 hari /
  30 hari) beserta ringkasan min/max/rata-rata.

### FR-4 Deteksi Kematangan
- Server menandai pupuk **matang** bila kadar NH3 ≥ ambang matang secara
  berkelanjutan selama durasi tertentu (default 30 menit).
- Saat matang, server membuat event/notifikasi.
- **Katup tidak terbuka otomatis.**

### FR-5 Kontrol Heater
- Firmware menyalakan heater otomatis saat suhu < `temp_min`.
- Firmware mematikan heater saat suhu ≥ `temp_min + hysteresis`.
- Safety: heater mati paksa bila suhu ≥ `temp_max` (default 45 °C) atau menyala
  terus melebihi `heater_max_on_min`.
- Operator dapat memaksa ON (dengan timeout), memaksa OFF, atau mengembalikan ke
  mode auto.

### FR-6 Kontrol Katup
- Katup hanya dibuka/ditutup melalui perintah manual dari aplikasi.
- Setiap perintah memiliki masa berlaku (TTL, default 60 detik) agar perintah
  basi tidak dieksekusi.
- Safety: katup menutup otomatis setelah `valve_max_open_min` (default 10 menit).

### FR-7 Notifikasi
- Aplikasi menampilkan daftar notifikasi (matang, suhu dingin/panas, perangkat
  offline, safety cutoff).
- Notifikasi dapat ditandai sudah dibaca.

### FR-8 Pengaturan
- Operator dapat mengubah: interval sampling, ambang suhu min/max, hysteresis,
  ambang NH3 matang, durasi tahan matang, mode heater, batas waktu safety.

### FR-9 Siklus/Batch
- Operator dapat memulai batch baru dan menandai batch telah dipanen.

### FR-10 Simulator Perangkat
- Tersedia simulator (script) untuk mengirim data palsu ke server agar
  pengembangan aplikasi & server tidak menunggu hardware.

## Kebutuhan Non-Fungsional

| Kode | Kebutuhan |
|---|---|
| NFR-1 | Aplikasi berjalan di Android dan Web dari satu basis kode Flutter |
| NFR-2 | Live value diperbarui ≤ interval polling (default 10 detik) |
| NFR-3 | Histori tahan lama; data mentah (raw) disimpan dengan kebijakan retensi (default 30 hari) |
| NFR-4 | Server menangani perangkat di belakang NAT tanpa port masuk (HTTP keluar) |
| NFR-5 | Komunikasi produksi via HTTPS/TLS |
| NFR-6 | Perangkat otomatis reconnect WiFi dan server dengan backoff |
| NFR-7 | UI responsif untuk layar ponsel dan desktop web |
| NFR-8 | Logika aman: heater & katup punya pengaman gagal-aman (fail-safe) |
| NFR-9 | Kode terdokumentasi dan sesuai konvensi (lihat `AGENTS.md`) |
| NFR-10 | Rahasia (token, kredensial DB) tidak pernah masuk repo |

## Use Case Utama
1. Operator membuka aplikasi → melihat suhu, NH3, dan status pupuk.
2. Pupuk matang → aplikasi menampilkan notifikasi.
3. Operator memeriksa grafik riwayat NH3 untuk memastikan tren.
4. Operator menekan "Buka Katup" → konfirmasi → server mengirim perintah →
   firmware membuka katup → status terbarui.
5. Suhu turun → heater menyala otomatis → status heater terlihat di aplikasi.
6. Operator menandai batch dipanen → siklus baru dimulai.

## Kriteria Penerimaan (ringkas)
- [ ] Data dari simulator/hardware muncul di dashboard < 1 interval.
- [ ] Histori tersampling sesuai interval dan tampil sebagai grafik.
- [ ] Event "matang" muncul saat ambang terpenuhi dan **tidak** membuka katup.
- [ ] Heater menyala/mati sesuai logika + safety.
- [ ] Katup hanya bergerak setelah perintah manual.
- [ ] Aplikasi berjalan di Android (`flutter run`) dan Web (`flutter run -d chrome`).
