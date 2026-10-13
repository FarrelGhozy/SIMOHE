#include "protocol.h"

#include <ctype.h>
#include <math.h>
#include <string.h>

namespace simohe {

const char* modeToString(HeaterMode mode) {
  switch (mode) {
    case HeaterMode::ForceOn:
      return "FORCE_ON";
    case HeaterMode::ForceOff:
      return "FORCE_OFF";
    case HeaterMode::Auto:
    default:
      return "AUTO";
  }
}

bool modeFromString(const char* text, HeaterMode& out) {
  if (text == nullptr) {
    return false;
  }
  // Samakan "auto"/"AUTO", "force_on"/"FORCE_ON", "force_off"/"FORCE_OFF".
  char upper[16];
  size_t i = 0;
  while (text[i] != '\0' && i < sizeof(upper) - 1) {
    upper[i] = (char)toupper((unsigned char)text[i]);
    i++;
  }
  upper[i] = '\0';
  if (text[i] != '\0') {
    return false;  // lebih panjang dari buffer perbandingan -> tolak
  }
  if (strcmp(upper, "AUTO") == 0) {
    out = HeaterMode::Auto;
    return true;
  }
  if (strcmp(upper, "FORCE_ON") == 0) {
    out = HeaterMode::ForceOn;
    return true;
  }
  if (strcmp(upper, "FORCE_OFF") == 0) {
    out = HeaterMode::ForceOff;
    return true;
  }
  return false;
}

namespace {

bool finiteFloat(float v) { return isfinite(v) != 0; }

uint16_t clampU16(uint32_t v, uint16_t lo, uint16_t hi) {
  if (v < lo) return lo;
  if (v > hi) return hi;
  return (uint16_t)v;
}

uint32_t clampU32(uint32_t v, uint32_t lo, uint32_t hi) {
  if (v < lo) return lo;
  if (v > hi) return hi;
  return v;
}

}  // namespace

bool sanitizeHeaterConfig(HeaterConfig& config) {
  bool ok = true;
  if (config.ingestIntervalSec < 1 || config.ingestIntervalSec > kMaxIngestIntervalSec) {
    config.ingestIntervalSec = clampU16(config.ingestIntervalSec, 1, kMaxIngestIntervalSec);
    ok = false;
  }
  if (!finiteFloat(config.tempMinC) || !finiteFloat(config.tempMaxC) ||
      config.tempMinC < kMinTempC || config.tempMaxC > kMaxTempC ||
      config.tempMinC >= config.tempMaxC) {
    if (!finiteFloat(config.tempMinC) || config.tempMinC < kMinTempC ||
        config.tempMinC >= config.tempMaxC) {
      config.tempMinC = 30.0f;
    }
    if (!finiteFloat(config.tempMaxC) || config.tempMaxC > kMaxTempC ||
        config.tempMinC >= config.tempMaxC) {
      config.tempMaxC = 45.0f;
    }
    ok = false;
  }
  if (!finiteFloat(config.hysteresisC) || config.hysteresisC < 0.0f ||
      config.hysteresisC > kMaxHysteresisC) {
    config.hysteresisC = 2.0f;
    ok = false;
  }
  if (!finiteFloat(config.nh3MaturePpm) || config.nh3MaturePpm <= 0.0f ||
      config.nh3MaturePpm > 1000.0f) {
    config.nh3MaturePpm = 25.0f;
    ok = false;
  }
  if (config.matureHoldMin == 0 || config.matureHoldMin > kMaxMinutes) {
    config.matureHoldMin = clampU32(config.matureHoldMin, 1, kMaxMinutes);
    ok = false;
  }
  if (config.heaterMaxOnMin == 0 || config.heaterMaxOnMin > kMaxMinutes) {
    config.heaterMaxOnMin = clampU32(config.heaterMaxOnMin, 1, kMaxMinutes);
    ok = false;
  }
  if (config.valveMaxOpenMin == 0 || config.valveMaxOpenMin > kMaxMinutes) {
    config.valveMaxOpenMin = clampU32(config.valveMaxOpenMin, 1, kMaxMinutes);
    ok = false;
  }
  if (config.commandTtlSec == 0 || config.commandTtlSec > kMaxCommandTtlSec) {
    config.commandTtlSec = clampU32(config.commandTtlSec, 1, kMaxCommandTtlSec);
    ok = false;
  }
  return ok;
}

}  // namespace simohe
