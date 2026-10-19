#pragma once

// Salin file ini menjadi `secrets.h` lalu isi nilai sebenarnya.
// `secrets.h` TIDAK di-commit (lihat .gitignore) agar kredensial tidak bocor.

#define SIMOHE_WIFI_SSID "nama-wifi"
#define SIMOHE_WIFI_PASSWORD "kata-sandi-wifi"
// URL project Supabase (wajib HTTPS), cth: "https://abcdefghijklm.supabase.co"
#define SIMOHE_BASE_URL "https://<ref>.supabase.co"
// Publishable/anon key Supabase (Dashboard → Project Settings → API).
// Kunci ini publik (RLS read-only); service_role TIDAK BOLEH di sini.
#define SIMOHE_ANON_KEY "GANTI_DENGAN_PUBLISHABLE_ATAU_ANON_KEY"
#define SIMOHE_DEVICE_KEY "GANTI_DENGAN_DEVICE_KEY"
