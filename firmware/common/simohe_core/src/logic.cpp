#include "logic.h"

#include "protocol.h"
#include "safe_str.h"

namespace simohe {

namespace {

uint32_t minutesToMs(uint32_t minutes) {
  if (minutes == 0) {
    minutes = 1;
  }
  if (minutes > kMaxMinutes) {
    minutes = kMaxMinutes;
  }
  return minutes * 60000UL;
}

bool autoHeater(bool previousOn, float tempC, const HeaterConfig& config) {
  if (previousOn) {
    return tempC < config.tempMinC + config.hysteresisC;
  }
  return tempC < config.tempMinC;
}

}  // namespace

void thermalStep(ThermalState& state, const HeaterConfig& config, bool tempOk, float tempC,
                 uint32_t nowMs) {
  const bool previous = state.heater;
  state.safetyCutoff = false;
  state.safetyReason = nullptr;

  // Cooldown pasca max-on: deadline di masa depan (overflow-safe, interval < 2^31).
  if (state.cooldownUntilMs != 0 && timeReached(nowMs, state.cooldownUntilMs)) {
    state.cooldownUntilMs = 0;
  }
  const bool cooldownActive = state.cooldownUntilMs != 0;

  if (!tempOk) {
    state.heater = false;
  } else if (cooldownActive) {
    state.heater = false;
  } else if (tempC >= config.tempMaxC) {
    state.heater = false;
    state.mode = HeaterMode::Auto;
    state.forceOnUntilMs = 0;
    state.safetyCutoff = true;
    state.safetyReason = "temp_high";
  } else {
    switch (state.mode) {
      case HeaterMode::ForceOff:
        state.heater = false;
        break;
      case HeaterMode::ForceOn:
        if (!timeReached(nowMs, state.forceOnUntilMs)) {
          state.heater = true;
        } else {
          state.mode = HeaterMode::Auto;
          state.forceOnUntilMs = 0;
          state.heater = autoHeater(previous, tempC, config);
        }
        break;
      case HeaterMode::Auto:
      default:
        state.heater = config.heaterAuto ? autoHeater(previous, tempC, config) : false;
        break;
    }
  }

  if (state.heater && !previous) {
    state.heaterOnSinceMs = nowMs;
  } else if (!state.heater) {
    state.heaterOnSinceMs = nowMs;
  }

  if (state.heater && (nowMs - state.heaterOnSinceMs) >= minutesToMs(config.heaterMaxOnMin)) {
    state.heater = false;
    state.mode = HeaterMode::Auto;
    state.forceOnUntilMs = 0;
    state.cooldownUntilMs = nowMs + minutesToMs(kHeaterCooldownMin);
    state.safetyCutoff = true;
    state.safetyReason = "heater_max_on";
  }

  state.heating = state.heater;
  state.heaterChanged = state.heater != previous;
}

void valveApplyOpen(ValveState& state, uint32_t nowMs) {
  if (!state.open) {
    state.openedAtMs = nowMs;
    state.open = true;
    state.changed = true;
  }
}

void valveApplyClose(ValveState& state) {
  if (state.open) {
    state.open = false;
    state.changed = true;
  }
}

void valveStep(ValveState& state, const HeaterConfig& config, uint32_t nowMs) {
  state.safetyClosed = false;
  if (!state.open) {
    return;
  }
  if ((nowMs - state.openedAtMs) >= minutesToMs(config.valveMaxOpenMin)) {
    state.open = false;
    state.safetyClosed = true;
    state.changed = true;
  }
}

void maturityStep(MaturityState& state, const HeaterConfig& config, bool nh3Ok, float nh3Ppm,
                  uint32_t nowMs) {
  uint32_t dtMs = 0;
  if (state.lastUpdateMs != 0 && nowMs != state.lastUpdateMs) {
    dtMs = nowMs - state.lastUpdateMs;  // unsigned wrap aman; clamp agar loncatan aneh tak dihitung penuh
    if (dtMs > 3600000UL) {
      dtMs = 3600000UL;
    }
  }
  state.lastUpdateMs = nowMs;

  if (nh3Ok && nh3Ppm >= config.nh3MaturePpm) {
    state.streakMs += dtMs;
  } else {
    state.streakMs = 0;
  }
  state.streakSec = state.streakMs / 1000UL;

  const uint32_t holdMs = minutesToMs(config.matureHoldMin);
  const bool nowMature = state.streakMs >= holdMs;
  state.justMatured = nowMature && !state.mature;
  state.mature = nowMature;
}

float maturityProgress(const MaturityState& state, const HeaterConfig& config) {
  const float holdSec = (float)(config.matureHoldMin * 60UL);
  if (holdSec <= 0.0f) {
    return 0.0f;
  }
  float progress = (float)state.streakSec / holdSec;
  if (progress > 1.0f) {
    progress = 1.0f;
  }
  return progress;
}

}  // namespace simohe
