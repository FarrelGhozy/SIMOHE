#pragma once

// Gunakan secrets.h bila tersedia (kredensial asli, tidak di-commit),
// jika tidak jatuh ke secrets.example.h agar tetap bisa dikompilasi.
#if __has_include("secrets.h")
#include "secrets.h"
#else
#include "secrets.example.h"
#endif

// Kompatibilitas: secrets.h lama (pra-Supabase) belum punya SIMOHE_ANON_KEY.
// Isi kunci Supabase di secrets.h; tanpa itu ingest ditolak (401).
#ifndef SIMOHE_ANON_KEY
#define SIMOHE_ANON_KEY ""
#endif
