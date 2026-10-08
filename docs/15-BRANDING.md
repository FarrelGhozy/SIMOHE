# 15 — Branding

Identitas visual **SIMOHE**. Sumber aset: paket
`SIMOHE_brand_assets_GOAT_LATEST` (logo kambing terbaru; logo sapi lama tidak
dipakai). Semua aset di repo sudah dioptimasi untuk aplikasi.

## Palet Warna

### Warna utama
| Nama | Hex | Pemakaian |
|---|---|---|
| Forest (primer) | `#084E34` | Seed tema, AppBar aksen, splash, ikon app |
| Forest dark | `#063A26` | Varian gelap primer |
| Accent green | `#3B9640` | Aksen, status **normal** |
| Sage | `#97B4A9` | Elemen sekunder |
| Sage dark | `#2D6953` | Teks/ikon sekunder |

### Netral
| Nama | Hex |
|---|---|
| Surface | `#FDFDFD` |
| Surface variant | `#EBEEF0` |
| Border | `#D1D7DC` |
| Ink | `#23292B` |

### Warna status (fungsional, terpisah dari brand)
| Status | Hex |
|---|---|
| normal | `#3B9640` |
| peringatan | `#EF6C00` |
| bahaya | `#C62828` |
| offline | `#757575` |

### Aksen ikon fitur
| Ikon | Aksen |
|---|---|
| Suhu air | `#1D83E3` (biru) |
| Gas amonia / Kematangan | `#825F43` (cokelat) |
| Heater | `#FC5911` (oranye) |
| Katup solenoid | `#0C5839` (hijau tua) |
| Kambing | `#0C5538` (hijau tua) |

## Aturan Logo
- **Emblem** (`assets/branding/emblem.png`): dipakai di AppBar, splash screen,
  empty state, favicon/adaptive icon foreground. Transparan.
- **Full logo** (`assets/branding/logo_full.png`): landing/About dan materi
  dokumentasi. Jangan dikecilkan hingga wordmark tak terbaca (< 160 px lebar).
- **Monochrome** (`assets/branding/logo_monochrome.png`): latar gelap atau
  konteks satu warna.
- Jaga ruang kosong minimal setinggi emblem di sekeliling logo; jangan
  memiringkan, mengubah warna, atau menambah efek.

## Inventaris Aset (di repo)
```
assets/
├── branding/
│   ├── emblem.png            # 384x384
│   ├── logo_full.png         # 900px lebar
│   └── logo_monochrome.png   # 800px lebar
└── icons/feature/            # 256x256, tile rounded (latar terang)
    ├── suhu_air.png
    ├── gas_amonia.png
    ├── heater.png
    ├── katup_solenoid.png
    ├── koneksi_device.png
    ├── kematangan_pupuk.png
    ├── notifikasi.png
    ├── kambing.png
    └── tanaman_proses.png
docs/branding/brand-sheet.png # arsip referensi (tidak di-ship)
```
Ikon launcher Android & web di-generate (lihat `docs/08-FLUTTER-APP.md`).

## Pemetaan Ikon → UI
| Ikon | Komponen |
|---|---|
| `suhu_air` | MetricCard suhu dashboard |
| `gas_amonia` | MetricCard NH3 dashboard |
| `kematangan_pupuk` | Kartu kematangan |
| `heater` | Kontrol cepat & Control heater |
| `katup_solenoid` | Kontrol cepat & Control katup |
| `koneksi_device` | Status/Device perangkat |
| `notifikasi` | Tab notifikasi |
| `kambing` / `tanaman_proses` | Aksen layar About/empty state |

Ikon fitur adalah **tile ilustratif berwarna** — dipakai apa adanya (tidak
di-tint). Warna status tetap mengikuti tabel status di atas.

## Prinsip
- Brand hijau hutan sebagai identitas utama; status fungsional tetap mudah
  dibedakan.
- Kontras tetap memenuhi aksesibilitas (lihat `docs/08`).
- Aset besar dioptimasi sebelum commit; sumber mentah disimpan di luar repo.
