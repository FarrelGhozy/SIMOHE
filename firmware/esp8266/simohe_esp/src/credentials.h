#pragma once

// Gunakan secrets.h bila tersedia (kredensial asli, tidak di-commit),
// jika tidak jatuh ke secrets.example.h agar tetap bisa dikompilasi.
#if __has_include("secrets.h")
#include "secrets.h"
#else
#include "secrets.example.h"
#endif
