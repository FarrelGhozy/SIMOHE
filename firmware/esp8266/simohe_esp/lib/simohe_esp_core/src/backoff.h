#pragma once

#include <stdint.h>

namespace simohe_esp {

constexpr uint32_t kBackoffBaseMs = 2000;
constexpr uint32_t kBackoffMaxMs = 60000;

// Delay backoff eksponensial: attempt 0 -> 2s, 1 -> 4s, ... dibatasi 60s.
uint32_t backoffDelayMs(uint32_t attempt);

}  // namespace simohe_esp
