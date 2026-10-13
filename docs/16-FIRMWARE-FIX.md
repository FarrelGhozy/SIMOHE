# 16 — Firmware Fix Backup (Audit + Rancangan Eksekusi)

Dokumen ini dibuat **di awal** sebagai backup sebelum perbaikan kode.
Jika eksekusi terkendala, dokumen ini menjadi acuan untuk rollback / lanjut manual.

Tanggal: 2026-10-13
Cakupan: `firmware/common/simohe_core`, `firmware/mega/simohe_mega`, `firmware/esp8266/simohe_esp`

## 1. Baseline yang diamankan

Uncommitted changes saat mulai (jangan hilangkan):
- `logic.cpp/h`: `heaterAuto` gate + `maturityStep` ms-resolution.
- `mega/main.ino`: debug `cal`/`status`, `calibrationDirty` save, hapus override `heaterAuto` ganda.
- `mega/bridge.cpp`: log `[cmd rx]`.
- `mega/config.h`: `SIMOHE_DEBUG`, Serial3, konstanta kalibrasi MQ (`A=40,B=-4.106`).
- `mega/sensors.*`: rescan bus, auto-kalibrasi R0 + EEPROM dirty flag.
- `esp/main.ino`: `sendConfigIfChanged()` (hemat Serial + EEPROM).
- `esp/config.h`: offline `8x1024`.
- `mega/platformio.ini`: `SERIAL_RX/TX_BUFFER_SIZE=256`.

Perilaku benar yang dipertahankan:
- Katup hanya manual, safety selalu menang, sensor gagal → heater OFF.
- Serial JSON `\n`, 115200 baud, Mega↔ESP Serial3.
- Ingest `POST /api/iot/ingest`, backoff 2s..60s, offline FIFO buang tertua.

## 2. Daftar bug yang dieksekusi (ringkas)

Kritis:
- K1: `thermalStep` max-on tidak latch → heater nyala lagi loop berikutnya.
- K2: event `SAFETY_CUTOFF temp_high` tiap loop → banjir serial.
- K3: `now >= nextMs` di ESP jebol saat `millis()` overflow.

Buffer/OOB:
- B1: `modeFromString` baca `text[7]` tanpa cek panjang.
- B2: `parseIso8601Utc` baca indeks tetap tanpa cek `strlen`.
- B3: `readLine` split-frame saat overlong (Mega+ESP).
- B4: `strncpy(...,sizeof-1)` tanpa terminator eksplisit di `EspBridge::sendCommand`.
- B5: `OfflineBuffer::push` truncate → JSON rusak.
- B6: `copyString` `capacity==0` underflow.

Logika rancu:
- R1: `heater_on` `durationMin*60000` tanpa clamp/overflow guard.
- R2: Megaabaikan `expires_*` (percaya ESP, ESP lolos saat `!timeSynced`).
- R3: config EEPROM tanpa validasi/CRC, tulis tiap frame.
- R4: `ingest_builder` lupa `nh3_ok`.
- R5: `drainOffline` terapkan config basi dari replay.
- R6: `parseIngestResponse` default dari nol bukan config berjalan + hanya `expires_at`.
- R7: `400` ikut di-buffer → poison queue.
- R8: `minutesToMs` / `holdMs` overflow bila config liar.
- R9: `configEquals` float `==` → kirim ulang tiap ingest bila jitter.
- R10: `ppm` tanpa filter, `MQ_CAL_MAX_SPREAD 0.5` longgar.
- R11: ESP tanpa `SERIAL_RX/TX_BUFFER_SIZE` (Mega sudah 256).
- R12: docs vs kode: `history_interval_min`, `ping.ts`, `events[].ts`, `expires_epoch`, buffer 8 vs 60.

## 3. Keputusan eksekusi

- Latch `heater_max_on`: cooldown 10 menit (`HEATER_COOLDOWN_MIN=10`), heater paksa OFF selama cooldown walau suhu dingin. Alasan: simpel, aman, tidak perlu state tambahan di server.
- Ping Mega: `seq` tetap pakai terakhir (tidak increment) tapi didokumenkan bukan duplikat berbahaya — alternatif increment akan merusak monoton? Dipilih: increment `seq` untuk ping juga agar monoton. (Update docs.)
- Offline tetap `8x1024`, docs disamakan (bukan 60). Alasan RAM ESP.
- `400` → drop, jangan buffer. `429/5xx/fail` → buffer + backoff.
- Expiry: bila `!timeSynced` dan command punya expiry → tunda (jangan kirim ke Mega) sampai sync. Bila command tanpa expiry → kirim.
- Validasi config: `tempMin<tempMax`, rentang waras (`-20..80`), `hyst 0..10`, `hold/max/ttl>0` dan clamp maks 1440 menit / 86400 detik. `NaN/Inf` ditolak.
- Kalibrasi: `SPREAD 0.5→0.2`, tambah filter ppm 8 sampel, tegaskan warmup 30s hanya transient (preheat 24h tetap wajib).

## 4. Urutan file yang diubah

1. `common/simohe_core/src/safe_str.h` (baru)
2. `common/simohe_core/src/protocol.*`, `time_parse.*`, `codec.*`, `logic.*`, `simohe_core.h`
3. `mega/.../bridge.*`, `main.ino`, `config_store.*`, `sensors.*`, `config.h`, `platformio.ini` (cek)
4. `esp/.../serial_bridge.*`, `main.ino`, `lib/.../ingest_builder.*`, `response.*`, `offline_buffer.*`, `api_client.*`, `wifi_manager.*`, `config.h`, `platformio.ini`
5. `*/test/test_logic/test_main.cpp` (tambah kasus)
6. `docs/04,05,09` + `TODO.md`

## 5. Cara rollback

- Semua perubahan kode terpisah dari dokumen ini.
- Bila build/test gagal: `git stash` / `git diff > /tmp/fix.patch` lalu `git checkout -- firmware/`, baca ulang dokumen ini untuk eksekusi manual per fase.
- Jangan hapus file ini sampai Fase 6 HIL lolos.

## 6. Status eksekusi (2026-10-13)

Dieksekusi penuh. Baseline hijau → sesudah hijau:
- Mega native: 16 → 22 test PASSED; `pio run -e mega` SUCCESS (RAM 30%, Flash 11%).
- ESP native: 8 → 13 test PASSED; `pio run -e esp` SUCCESS (RAM 52%, Flash 39%).
- `strncpy` mentah habis (0 sisa); parser OOB ditutup; docs 04/05/09 + TODO disinkronkan.
- HIL ulang yang disarankan: heater max-on latch 10 mnt, spam safety (tahan panas),
  cabut sensor, WiFi mati (replay 8 frame), command expired saat ESP belum sync,
  config liar (tempMin>tempMax), `cal`/`status` via USB.
