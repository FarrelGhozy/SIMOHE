# 15 — Branding

Identitas visual **SIMOHE**. Sumber aset: paket
`SIMOHE_brand_assets_GOAT_LATEST` (logo kambing terbaru; logo sapi lama tidak
dipakai).

> Catatan: ikon fitur berwarna dari paket tidak dipakai (banyak yang kurang
> pas). UI kembali memakai ikon **Material** bawaan. Aset brand yang dipakai
> hanya **emblem** dan **logo monochrome**.

## Palet Warna

### Warna utama
| Nama | Hex | Pemakaian |
|---|---|---|
| Forest (primer) | `#084E34` | Seed tema, aksen |
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

## Aturan Logo
- **Emblem** (`assets/branding/emblem.png`): dipakai di AppBar Dashboard dan
  splash screen Android. Transparan.
- **Monochrome** (`assets/branding/logo_monochrome.png`): konteks satu warna /
  latar terang, materi dokumentasi.
- Jaga ruang kosong minimal setinggi emblem di sekeliling logo; jangan
  memiringkan atau mengubah warna.

## Inventaris Aset (di repo)
```
assets/branding/
├── emblem.png            # 384x384, transparan
└── logo_monochrome.png   # 800px lebar
docs/branding/brand-sheet.png  # arsip referensi (tidak di-ship)
branding/                 # sumber ikon launcher & splash (tidak di-ship)
```
Ikon launcher Android & web di-generate (lihat `docs/08-FLUTTER-APP.md`).

## Prinsip
- Brand hijau hutan sebagai identitas utama; status fungsional tetap mudah
  dibedakan.
- Kontras tetap memenuhi aksesibilitas (lihat `docs/08`).
- Aset besar dioptimasi sebelum commit; sumber mentah disimpan di luar repo.
