#pragma once

#include <stdint.h>

#include "protocol.h"

namespace simohe {

struct ThermalState {
  HeaterMode mode = HeaterMode::Auto;
  bool heater = false;
  uint32_t forceOnUntilMs = 0;
  uint32_t heaterOnSinceMs = 0;
  bool heating = false;
  bool safetyCutoff = false;
  const char* safetyReason = nullptr;
  bool heaterChanged = false;
};

struct ValveState {
  bool open = false;
  uint32_t openedAtMs = 0;
  bool safetyClosed = false;
  bool changed = false;
};

struct MaturityState {
  uint32_t streakSec = 0;
  bool mature = false;
  uint32_t lastUpdateMs = 0;
  bool justMatured = false;
};

void thermalStep(ThermalState& state, const HeaterConfig& config, bool tempOk, float tempC,
                 uint32_t nowMs);

void valveApplyOpen(ValveState& state, uint32_t nowMs);
void valveApplyClose(ValveState& state);
void valveStep(ValveState& state, const HeaterConfig& config, uint32_t nowMs);

void maturityStep(MaturityState& state, const HeaterConfig& config, bool nh3Ok, float nh3Ppm,
                  uint32_t nowMs);

float maturityProgress(const MaturityState& state, const HeaterConfig& config);

}  // namespace simohe
