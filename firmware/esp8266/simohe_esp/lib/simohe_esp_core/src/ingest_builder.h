#pragma once

#include <stddef.h>

#include <simohe_core.h>

namespace simohe_esp {

struct EventItem {
  const char* code;
  const char* detail;
};

struct AckItem {
  const char* id;
  bool ok;
};

// Membentuk body JSON untuk POST /api/iot/ingest. Mengembalikan panjang body
// atau 0 bila gagal. Tidak menambahkan newline.
size_t buildIngestBody(const simohe::Telemetry& telemetry, const char* firmware, const char* ts,
                       const EventItem* events, size_t eventCount, const AckItem* acks,
                       size_t ackCount, char* out, size_t outSize);

}  // namespace simohe_esp
