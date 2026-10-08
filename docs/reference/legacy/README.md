# Arsip Proyek Lama — Sebelum Rebuild

Folder ini menyimpan materi **proyek SIMOHE versi lama** yang sudah **tidak
dipakai** setelah rebuild total. Disimpan hanya sebagai referensi historis.

## Isi
- `IoT_KOHE/` — dokumentasi & firmware lama:
  - `IoT_KOHE.ino` — firmware lama (sensor ultrasonik JSN-SR04T + relay katup,
    membuka katup **otomatis**).
  - `Flowchart 1` — flowchart lama.
  - `Alur IoT` — catatan alur/wiring lama (panel surya, aki, step-down).
  - `Wireingnya` — diagram kabel lama.

## Mengapa Diarsipkan
Konsep lama berbeda dari konsep baru:
| Aspek | Lama | Baru (SIMOHE) |
|---|---|---|
| Sensor | Ultrasonik (volume) + amonia | **Suhu air (DS18B20)** + **amonia (MQ-137)** |
| Pemicu | Volume penuh / bau → buka katup otomatis | **Kematangan (NH3)** → notifikasi, katup **manual** |
| Aktuator | 1 relay (katup) | **2 relay**: katup (K1) + **heater** (K2) |
| Aplikasi | Android native (Kotlin/XML), data acak | **Flutter** (Android + Web), data nyata |
| Server | Tidak ada | **Bun + Elysia + MySQL** |
| Histori | Tidak ada | **Tersampling + grafik** |

## Status
- Kode Android lama (folder `app/`, `gradle/`, dll) **sudah dihapus** dari repo.
- Hanya catatan/firmware IoT lama yang disimpan di sini untuk kenang-kenangan &
  referensi wiring kelistrikan (panel surya/aki) yang masih bisa relevan.

> Semua rancangan baru ada di `docs/`. Jangan gunakan logika di folder ini.
