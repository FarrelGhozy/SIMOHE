#pragma once

#include <stdint.h>

namespace simohe {

// Mengubah "YYYY-MM-DDThh:mm:ssZ" (UTC) menjadi epoch detik (Unix).
// Mengembalikan 0 bila format tidak valid.
uint32_t parseIso8601Utc(const char* text);

}  // namespace simohe
