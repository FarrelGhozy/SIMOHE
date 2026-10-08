#pragma once

#include <stdint.h>

#include <simohe_core.h>

namespace config_store {

bool load(simohe::HeaterConfig& config, float& r0, bool& r0Calibrated);
void save(const simohe::HeaterConfig& config, float r0, bool r0Calibrated);

}  // namespace config_store
