# 13 — Testing Strategy

> **Migrasi 2026-10-14 (Fase 8)**: bagian `Bun test`, simulator Bun, dan hasil
> Fase 4/5/6 di bawah adalah **arsip pra-Supabase** (server lama di
> `reference/archive/server-bun-2026-10-14/`). Verifikasi aktif: §12.

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
Script yang meniru ESP untuk menguji server & aplikasi tanpa hardware
(`server/tools/simulator/`). Dijalankan dengan `bun run sim`:
```bash
bun run sim -- --device-key <KEY>                         # skenario normal
bun run sim -- --device-key <KEY> --scenario offline      # uji device_offline
bun run sim -- --device-key <KEY> --scenario overheat     # uji safety_cutoff
bun run sim -- --device-key <KEY> --autoconfig --app-token <TOKEN>
```
- Skenario: `normal` (suhu naik-turun memicu heater), `mature` (NH3 naik
  pelan melewati ambang), `offline` (berhenti mengirim sesaat), `overheat`.
- Menerapkan `commands` dari respons ingest lalu mengirim `acks`.
- `--autoconfig` menyetel `history_interval_min`/`mature_hold_min` agar histori
  dan kematangan cepat terverifikasi.
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
### Unit (host, tanpa hardware)
Logika murni diuji dengan Unity lewat PlatformIO `native`:
```bash
cd firmware/mega/simohe_mega && pio test -e native
cd firmware/esp8266/simohe_esp && pio test -e native
```
Cakupan: heater/safety/hysteresis, auto-close katup, kematangan, konversi
Rs→ppm, filter rata-rata, encode/decode JSON frame, parser respons server,
buffer offline, backoff, dan format waktu ISO-8601 UTC.

Kompilasi kedua target juga menjadi gerbang: `pio run -e mega`,
`pio run -e esp`.

### Bench (per komponen) — butuh hardware, Fase 6
- DS18B20: bandingkan dengan termometer referensi (±0.5 °C).
- MQ-137: preheat, kalibrasi R0, cek tren terhadap gas uji (opsional).
- Relay: verifikasi K1/K2 menyala sesuai perintah, idle = OFF.
- Serial Mega↔ESP: kirim/terima frame JSON valid, tangani baris rusak.

### HIL (terintegrasi) — Fase 6
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

## 9. Hasil Uji Fase 4 (Simulasi)
Diuji tanpa hardware memakai server + simulator, plus aplikasi Flutter web.

### Perintah
```bash
cd server
bun test            # unit + integration + e2e (56 test)
bun run test:e2e    # khusus matriks T1–T10 (8 test)

# live smoke (server + simulator). Lihat tools/e2e/smoke.sh
./tools/e2e/smoke.sh normal 20 2
```
Aplikasi: `flutter run -d chrome --web-port 8080 \
  --dart-define=API_BASE_URL=http://localhost:3000 \
  --dart-define=APP_TOKEN=<APP_TOKEN>`.

### Matriks T1–T10
| ID | Skenario | Hasil | Bukti |
|---|---|---|---|
| T1 | suhu 27 °C | heater ON + event `temp_low` | `tests/e2e/matrix.test.ts`, smoke normal |
| T2 | suhu 36 °C | heater OFF + event `heater_off` | e2e |
| T3 | suhu 46 °C | heater OFF, event `temp_high` + `safety_cutoff` | e2e (skenario overheat) |
| T4 | NH3 26 ppm ~29 menit | belum matang (progress < 1) | e2e (elapsed disimulasi) |
| T5 | NH3 26 ppm ≥ 31 menit | event `mature`, katup tetap tertutup, batch `mature` | e2e |
| T6 | POST `valve_open` | `pending` → `sent` → `acked` | e2e + UI live (Kontrol) |
| T7 | command lewat TTL | `expired`, tidak dikirim saat ingest | e2e |
| T8 | katup buka > `valve_max_open_min` | auto-close + event `safety_cutoff` | e2e (safety simulator) |
| T9 | tanpa ingest > 3× interval | event `device_offline` | e2e |
| T10 | ingest kembali | event `device_online` | e2e |

**Status: lulus** (8 test e2e, 0 gagal; 56 test server total).

### Verifikasi Aplikasi (live smoke)
Server + simulator + Flutter web berjalan bersamaan. Diverifikasi:
- **Dashboard**: metrik live (suhu, NH3), status, kematangan, kontrol cepat, tren 24 jam.
- **History**: rentang, grafik suhu/NH3, ringkasan min/max/avg, ekspor CSV.
- **Control**: dialog konfirmasi + info safety; buka/tutup katup ter-`acked`
  otomatis (polling status perintah); heater AUTO/ON/OFF.
- **Notifications**: daftar event (matang, suhu, offline, katup) + filter & tandai dibaca.
- **Settings**: nilai dari server; **Device**: status, firmware, last_seen, siklus.
- Aturan keras dipenuhi: saat `mature` katup **tetap tertutup** (hanya manual).

### Perbaikan selama Fase 4
- Simulator mengimplementasikan **auto-close katup** (T8).
- Server mengabaikan **kode event perangkat tak dikenal** (sebelumnya keliru
  menjadi `safety_cutoff`).
- Aplikasi menambah **polling status perintah** (5 detik).

## 10. Hasil Uji Fase 5 (Firmware, tanpa hardware)
Firmware dibangun dan diuji tanpa perangkat keras memakai PlatformIO.

### Perintah
```bash
cd firmware/mega/simohe_mega
pio test -e native        # 14 test: logika, gas, codec, waktu
pio run  -e mega          # kompilasi AVR (megaatmega2560)

cd firmware/esp8266/simohe_esp
pio test -e native        # 8 test: backoff, buffer, respons, ingest, waktu
pio run  -e esp           # kompilasi ESP8266 (nodemcuv2)
```

| Tahap | Hasil |
|---|---|
| Unit test Mega (`simohe_core`) | 14 lulus |
| Unit test ESP (`simohe_esp_core`) | 8 lulus |
| Build Mega | sukses (Flash 9.3%, RAM 19.2%) |
| Build ESP | sukses (Flash 38.8%, RAM 50%) |

Cakupan: state machine heater + safety (temp high, heater max-on, fail-safe
sensor), auto-close katup, kematangan, Rs→ppm MQ-137, filter rata-rata,
encode/decode frame, parser respons ingest, buffer offline + backoff, dan
format waktu ISO-8601 UTC.

**Status: lulus.** Bench per komponen & HIL (fase 6) menunggu hardware.

## 11. Hasil Uji Fase 6 (Hardware, sebagian)
Board: **RobotDyn MEGA+WiFi R3** (ATmega2560 + ESP8266, CH340G, 8 DIP switch).
Mega↔ESP terhubung lewat **Serial3 (pin 14/15)**.

### Prosedur flash (dipakai)
```bash
# Mega — set DIP 3,4 = ON
cd firmware/mega/simohe_mega
pio run -e mega && pio run -e mega -t upload --upload-port /dev/ttyUSB0

# ESP — set DIP 5,6,7 = ON (auto-reset jalan, tanpa tombol Mode)
cd firmware/esp8266/simohe_esp
pio run -e esp && pio run -e esp -t upload --upload-port /dev/ttyUSB0

# Mode jalan — set DIP 1,2,3,4 = ON
```
`secrets.h` ESP diisi SSID/password, `SIMOHE_BASE_URL=http://<LAN-IP>:3000`,
dan `SIMOHE_DEVICE_KEY` (plaintext; server menyimpan hash-nya).

### Hasil
| Uji | Hasil |
|---|---|
| Flash Mega | lulus (23532 byte, verify OK) |
| Flash ESP | lulus (409168 byte, hash verified) |
| Jalur Mega→ESP→server (Serial3) | lulus — device `online`, fw `0.1.0` |
| Fail-safe sensor absen | lulus — status `error`, heater OFF, valve OFF |
| Perintah app end-to-end | lulus — `heater_on` `pending→sent→acked`, mode `FORCE_ON` |
| Mode kembali via perintah | lulus — `heater_auto` → mode `AUTO` |

### Perbaikan selama Fase 6
- **Port Serial board**: Mega↔ESP di **Serial3 (14/15)**, bukan Serial2. Diubah di
  `config.h`; docs 03/04 disinkronkan.
- **Byte terbuang pada Serial3**: buffer RX AVR hanya 64 byte sementara ESP kerap
  mengirim `config` + `cmd` berurutan, sehingga frame `cmd` tergabung/terpotong
  dan JSON invalid (command tak pernah di-`ack`). Perbaikan:
  `SERIAL_RX_BUFFER_SIZE=256` & `SERIAL_TX_BUFFER_SIZE=256` (build_flags Mega),
  dan ESP hanya mengirim `config` saat nilainya berubah.
- **Debug bench**: Mega mencetak `[cmd rx]` / `[cmd] ... ok` ke Serial0
  (USB) saat `SIMOHE_DEBUG=1`.

### Perbaikan pasca-audit sensor (sebelum flash ulang)
Ditemukan saat audit bahwa sensor tak terbaca. Perbaikan yang diterapkan:
- **MQ-137 R0 selalu null**: `r0Calibrated` tak pernah di-set. Ditambah kalibrasi
  R0 otomatis sekali (udara bersih) + simpan EEPROM, dan pemicu serial `cal`.
  Kurva diperbaiki ke `a=40.0`, `b=-4.106` (datasheet MQ-137).
- **DS18B20**: tambah `setResolution(12)`, diagnostik `getDeviceCount`, dan
  pemindaian ulang bus tiap 5 detik bila sensor absen.
- **Kematangan Mega tak pernah naik**: `maturityStep` memakai delta detik yang
  selalu 0 pada loop cepat; diubah ke akumulasi milidetik.
- **Telemetry banjir saat `heater_auto=false`**: pengecekan `heaterAuto` dipindah
  ke `thermalStep` (intinya) sehingga tidak mengganti state tiap loop.
- **Buffer offline ESP terpotong**: `OFFLINE_FRAME_SIZE` dinaikkan 224 → 1024
  (kapasitas 30 → 8 agar RAM aman).
- **Server**: `latest_state.updated_at` kini di-set eksplisit (sebelumnya beku
  saat nilai tak berubah) dan `temp_ok` diturunkan dari `temp_c` bila tak dikirim.

Checklist HIL (poin 4) ditambah butir: firmware melaporkan sensor suhu & NH3
terbaca (`temp_ok`/`nh3_ok` = true) setelah kalibrasi.

### Checklist HIL (poin 4)
- [x] Telemetry muncul di server tiap interval.
- [ ] Heater nyala saat suhu < min, mati saat ≥ min+hyst.
- [ ] Safety cutoff (suhu tinggi & heater max on) bekerja.
- [ ] Katup hanya bergerak setelah perintah app; auto-close saat max open.
- [ ] Perintah basi (lewat TTL) tidak dieksekusi.
- [ ] WiFi dicabut → reconnect dengan backoff; telemetry pulih.
- [ ] Server mati → ESP buffer & kirim ulang saat pulih.
- [ ] Restart Mega/ESP → config dari EEPROM/server tetap benar.

**Status: sebagian lulus.** Bench per komponen & sisa checklist HIL menunggu
proses wiring oleh pengguna.

## 12. Verifikasi Supabase (Fase 8, menunggu project)

Backend Bun diganti Edge Functions; matriks T1–T10 diuji ulang via
`supabase/tools/sim-curl.sh` + aplikasi setelah project dibuat
(`supabase/SETUP.md` §7). Checklist:

- [ ] T1 suhu 27 °C → event `temp_low`
- [ ] T2 suhu 36 °C → heater OFF
- [ ] T3 suhu 46 °C → `temp_high` + `safety_cutoff`
- [ ] T4 NH3 26 ppm ~29 mnt → belum matang (progress < 1)
- [ ] T5 NH3 26 ppm ≥ 31 mnt → event `mature`, katup tetap tertutup
- [ ] T6 `app-command valve_open` → `pending→sent→acked` (sim-curl meng-ack)
- [ ] T7 command lewat TTL → `expired`
- [ ] T8 event `SAFETY_CUTOFF` perangkat tersimpan (`sim-curl.sh safety`)
- [ ] T9 tanpa ingest > 3× interval → `device_offline` (tunggu cron)
- [ ] T10 ingest lagi → `device_online`
- [ ] Sampling → `sensor_readings` bertambah per `history_interval_min`
- [ ] App: katup dibuka/ditutup dari Control, tercatat di commands+events

Yang sudah hijau tanpa cloud (2026-10-14):
- `flutter analyze`: bersih; `flutter test`: 20/20 lulus.
- ESP: `pio test -e native` 13/13 + `pio run -e esp` sukses.
- Mega: `pio test -e native` 22/22 + `pio run -e mega` sukses.
- Functions: `tsc --strict` bersih (kecuali resolusi `jsr:` runtime Deno).

