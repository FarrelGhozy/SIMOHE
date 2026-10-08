# 09 — Business Logic

Dokumen ini adalah sumber kebenaran untuk logika. Implementasi server ada di
`server/src/services/`, implementasi firmware di `firmware/`.

## 1. Logika Kematangan Pupuk

### Definisi
Pupuk dianggap **matang** bila kadar gas NH3 berada pada atau di atas ambang
matang secara **berkelanjutan** selama durasi tertentu.

### Parameter
| Nama | Default | Keterangan |
|---|---|---|
| `nh3_mature_ppm` | 25.0 | Ambang NH3 matang (ppm) |
| `mature_hold_min` | 30 | Durasi NH3 harus bertahan di atas ambang |
| `temp_min_c` | 30.0 | Suhu minimum fermentasi |
| `temp_max_c` | 45.0 | Batas aman atas (safety) |

### Algoritma (server, pada tiap ingest)
```
jika nh3_ppm >= nh3_mature_ppm:
    mature_streak += elapsed_since_last_ingest
sino:
    mature_streak = 0

progress = min(mature_streak / (mature_hold_min * 60), 1.0)

jika progress >= 1.0 dan status != 'mature':
    status = 'mature'
    buat event MATURE (severity: info/warning)
    set batch.matured_at
```

### Aturan Penting
- **Katup TIDAK dibuka otomatis** saat matang. Operator harus membukanya dari
  aplikasi.
- `mature_streak` di-reset bila NH3 turun di bawah ambang (harus berkelanjutan).
- Hasil tetap dilaporkan sebagai `maturity.progress` (0..1) ke aplikasi sehingga
  operator melihat "seberapa dekat" ke matang.

## 2. Logika Suhu & Heater

### Mode
- `AUTO` — firmware mengontrol penuh.
- `FORCE_ON` — dipaksa menyala dengan durasi (auto-expire).
- `FORCE_OFF` — dipaksa mati.

### Algoritma (firmware)
```
jika temp tidak valid (sensor error):
    heater = OFF
    mode_efektif = OFF   # fail-safe

selain itu:
  jika mode == AUTO:
      jika temp < temp_min_c: heater = ON
      jika temp >= temp_min_c + temp_hysteresis_c: heater = OFF
  jika mode == FORCE_ON dan now < deadline: heater = ON
  jika mode == FORCE_ON dan now >= deadline: mode = AUTO

  # Safety selalu menang
  jika temp >= temp_max_c:
      heater = OFF
      mode = AUTO
      kirim event SAFETY_CUTOFF (temp_high)
  jika heater ON terus > heater_max_on_min:
      heater = OFF
      mode = AUTO
      kirim event SAFETY_CUTOFF (heater_max_on)
```
- **Hysteresis** mencegah heater berkedip (on/off cepat).
- Saat suhu turun jauh (mis. < `temp_min_c - 5`), server membuat event
  `temp_low` (peringatan), terpisah dari aksi heater.

### Event Suhu
| Kondisi | Event | Severity |
|---|---|---|
| `temp < temp_min_c` | `temp_low` | warning |
| `temp >= temp_max_c` | `temp_high` | critical |
| Heater menyala | `heater_on` | info |
| Heater mati | `heater_off` | info |
| Safety memaksa mati | `safety_cutoff` | critical |

## 3. Logika Katup (Solenoid)

- **Hanya** berubah karena perintah manual dari aplikasi.
- Alur perintah:
  1. App → `POST /api/commands` (`valve_open`/`valve_close`).
  2. Server membuat command `pending` dengan `expires_at = now + command_ttl_sec`.
  3. ESP mengambil command saat ingest berikutnya → server tandai `sent`.
  4. ESP → Mega mengeksekusi → ack → server tandai `acked`.
  5. Bila lewat TTL sebelum diambil → `expired` (tidak dieksekusi).
- **Safety auto-close**: setelah terbuka `valve_max_open_min`, firmware menutup
  paksa + event `safety_cutoff`.

### Mengapa TTL?
Agar perintah basi (mis. dibuat saat device offline, lalu online lama kemudian)
tidak membuka katup pada waktu yang tidak diinginkan.

## 4. Status Perangkat & Offline

- `last_seen_at` diperbarui setiap ingest sukses.
- Bila `now - last_seen_at > 3 × ingest_interval_sec` → `is_online = false`,
  buat event `device_offline` (sekali per transisi).
- Saat ingest lagi → `device_online`, event `device_online`.

## 5. Siklus/Batch

```
POST /api/batches
  -> batch baru status 'fermenting', mature_streak = 0

saat MATURE terdeteksi:
  -> batch.matured_at = now, status 'mature'

POST /api/batches/:id/harvest
  -> batch.harvested_at = now, status 'harvested'
  -> (opsional) auto-buat batch baru
```

## 6. Prioritas Aksi (urutan penting)
1. **Safety** (sensor gagal, suhu terlalu tinggi, heater terlalu lama) — selalu
   menang, tidak bisa dioverride.
2. **Perintah manual** (mode heater, buka/tutup katup) — berlaku selama tidak
   melanggar safety.
3. **Otomatis** (heater AUTO berbasis suhu) — berlaku saat mode AUTO.
4. **Deteksi & notifikasi** (matang, offline) — tidak mengubah aktuator.

## 7. Contoh Skenario Uji Logika
| Skenario | NH3 | Suhu | Ekspektasi |
|---|---|---|---|
| Fermentasi normal | 10 ppm | 33 °C | Heater OFF, status idle |
| Suhu dingin | 10 ppm | 27 °C | Heater ON, event temp_low |
| Mendekati matang | 25 ppm 15 menit | 34 °C | progress 0.5, belum matang |
| Matang | 26 ppm 31 menit | 34 °C | event MATURE, katup tetap tertutup |
| Overheat | 26 ppm | 46 °C | heater OFF, event temp_high + safety_cutoff |
| Buka katup | — | — | Butuh perintah app; auto-close 10 menit |

Detail pengujian: `13-TESTING.md`.
