#pragma once

#include <stddef.h>
#include <stdint.h>

#include <simohe_core.h>

namespace simohe_esp {

constexpr size_t kMaxCommands = 4;

struct ServerCommand {
  char id[simohe::kMaxIdLen] = {0};
  char action[simohe::kMaxActionLen] = {0};
  uint32_t durationMin = 30;
  bool hasExpiry = false;
  uint32_t expiresAtEpoch = 0;
};

struct IngestResult {
  bool valid = false;
  simohe::HeaterConfig config;
  uint16_t pollAfterSec = 0;
  char serverTime[24] = {0};
  ServerCommand commands[kMaxCommands];
  size_t commandCount = 0;
};

bool parseIngestResponse(const char* json, IngestResult& out);

}  // namespace simohe_esp
