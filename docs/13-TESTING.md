# 13 — Testing Strategy

## Prinsip
- Uji logika bisnis tanpa hardware dulu (server + simulator).
- Hardware diuji belakangan dengan checklist HIL (hardware-in-the-loop).
- Setiap fitur punya kriteria lulus yang jelas.

## 1. Server (Bun test)
### Unit
- `maturity.ts`: streak, reset, progress, event sekali per transisi.
- `thermal.ts`: AUTO, hysteresis, FORCE_ON expiry, safety cutoff.
- `command.ts`: TTL, status transitions (pending→sent→acked/expired).
- `event.ts`: deduplikasi per transisi.

### Integration (DB test terpisah)
- Ingest → `latest_state` diperbarui + config/commands dikembalikan.
- Auth: device key salah → 401; app token salah → 401.
- Sampling job menulis ke `sensor_readings`.
- Offline detector membuat event `device_offline`.
- Alur command end-to-end (POST → diambil ingest → ack → status `acked`).

### Perintah
```bash
cd server
bun test
bun run lint
bun run typecheck
```

## 2. Device Simulator (kunci pengembangan awal)
Script yang meniru ESP untuk menguji server & aplikasi tanpa hardware:
```
server/tools/simulator.ts
  - POST /api/iot/ingest tiap 10s dengan skenario:
      * suhu naik-turun (memicu heater)
      * NH3 naik pelan (memicu matang setelah hold)
      * sesekali "offline" untuk uji device_offline
  - Menerima commands dan mencetak ack
```
Manfaat: aplikasi & server bisa dibangun dan diuji penuh sebelum firmware siap.

## 3. Aplikasi Flutter
### Widget test
- `MetricCard`, `StatusBadge`, `TrendChart` merender nilai dengan benar.
- Dashboard menampilkan status offline/online.
- Dialog konfirmasi membuka katup muncul & mengirim perintah.

### Unit
- Mapper model (JSON → domain).
- Logika status/warna dari nilai sensor.

### Integration
- `integration_test` dengan server mock: buka dashboard, kontrol katup,
  lihat notifikasi.

```bash
flutter analyze
flutter test
flutter test integration_test
```

## 4. Firmware
### Bench (per komponen)
- DS18B20: bandingkan dengan termometer referensi (±0.5 °C).
- MQ-137: preheat, kalibrasi R0, cek tren terhadap gas uji (opsional).
- Relay: verifikasi K1/K2 menyala sesuai perintah, idle = OFF.
- Serial Mega↔ESP: kirim/terima frame JSON valid, tangani baris rusak.

### HIL (terintegrasi)
Checklist:
- [ ] Telemetry muncul di server tiap interval.
- [ ] Heater nyala saat suhu < min, mati saat ≥ min+hyst.
- [ ] Safety cutoff (suhu tinggi & heater max on) bekerja.
- [ ] Katup hanya bergerak setelah perintah app; auto-close saat max open.
- [ ] Perintah basi (lewat TTL) tidak dieksekusi.
- [ ] WiFi dicabut → reconnect dengan backoff; telemetry pulih.
- [ ] Server mati → ESP buffer & kirim ulang saat pulih.
- [ ] Restart Mega/ESP → config dari EEPROM/server tetap benar.

## 5. End-to-End
- Jalankan server + (simulator atau hardware) + aplikasi.
- Skenario: suhu dingin → heater; NH3 naik → matang → notifikasi → buka katup →
  ack → auto-close; tandai panen → batch baru.

## 6. Matriks Uji Logika Bisnis
| ID | Input | Aksi | Hasil diharapkan |
|---|---|---|---|
| T1 | suhu 27 °C | — | heater ON, event temp_low |
| T2 | suhu 36 °C | — | heater OFF |
| T3 | suhu 46 °C | — | heater OFF, safety_cutoff |
| T4 | NH3 25 ppm 29 menit | — | belum matang |
| T5 | NH3 26 ppm 31 menit | — | event mature, katup tetap tutup |
| T6 | — | POST valve_open | command pending→sent→acked |
| T7 | command buat, device offline 5 menit | — | command expired, tidak dieksekusi |
| T8 | katup buka > max_open | — | auto-close + safety_cutoff |
| T9 | tidak ada ingest 5 menit | — | event device_offline |
| T10 | ingest lagi | — | event device_online |

## 7. Endpoint Uji Cepat
```bash
curl http://localhost:3000/api/health
curl http://localhost:3000/api/live -H 'Authorization: Bearer APPT0KEN'
```

## 8. Kriteria Lulus Rilis
- Semua unit & integration test server lulus.
- `flutter analyze` bersih, widget test lulus.
- Checklist HIL tercentang pada hardware nyata.
- Tidak ada rahasia di repo.
