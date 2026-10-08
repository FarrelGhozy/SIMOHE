#include "backoff.h"

namespace simohe_esp {

uint32_t backoffDelayMs(uint32_t attempt) {
  if (attempt > 30) {
    attempt = 30;
  }
  uint32_t delay = kBackoffBaseMs;
  for (uint32_t i = 0; i < attempt; i++) {
    if (delay >= kBackoffMaxMs) {
      return kBackoffMaxMs;
    }
    delay *= 2;
  }
  return delay > kBackoffMaxMs ? kBackoffMaxMs : delay;
}

}  // namespace simohe_esp
