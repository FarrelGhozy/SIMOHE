#pragma once

#include <stddef.h>
#include <stdint.h>

namespace simohe {

// Mengubah "YYYY-MM-DDThh:mm:ssZ" (UTC) menjadi epoch detik (Unix).
// Mengembalikan 0 bila format tidak valid.
uint32_t parseIso8601Utc(const char* text);

// Memformat epoch detik (Unix) menjadi "YYYY-MM-DDThh:mm:ssZ".
// Mengembalikan panjang string (tanpa null) atau 0 bila gagal/epoch 0.
size_t formatIso8601Utc(uint32_t epoch, char* out, size_t outSize);

}  // namespace simohe
