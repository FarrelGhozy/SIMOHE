#include "config_store.h"

#include <EEPROM.h>

namespace config_store {

namespace {

constexpr uint16_t kMagic = 0x5348;  // 'S''H'
constexpr uint16_t kVersion = 1;

struct StoredConfig {
  uint16_t magic;
  uint16_t version;
  uint16_t ingestIntervalSec;
  uint8_t heaterAuto;
  uint8_t r0Calibrated;
  float tempMinC;
  float tempMaxC;
  float hysteresisC;
  float nh3MaturePpm;
  uint32_t matureHoldMin;
  uint32_t heaterMaxOnMin;
  uint32_t valveMaxOpenMin;
  uint32_t commandTtlSec;
  float r0;
};

}  // namespace

bool load(simohe::HeaterConfig& config, float& r0, bool& r0Calibrated) {
  StoredConfig stored;
  EEPROM.get(0, stored);
  if (stored.magic != kMagic || stored.version != kVersion) {
    r0Calibrated = false;
    return false;
  }
  config.ingestIntervalSec = stored.ingestIntervalSec;
  config.heaterAuto = stored.heaterAuto != 0;
  config.tempMinC = stored.tempMinC;
  config.tempMaxC = stored.tempMaxC;
  config.hysteresisC = stored.hysteresisC;
  config.nh3MaturePpm = stored.nh3MaturePpm;
  config.matureHoldMin = stored.matureHoldMin;
  config.heaterMaxOnMin = stored.heaterMaxOnMin;
  config.valveMaxOpenMin = stored.valveMaxOpenMin;
  config.commandTtlSec = stored.commandTtlSec;
  r0 = stored.r0;
  r0Calibrated = stored.r0Calibrated != 0;
  return true;
}

void save(const simohe::HeaterConfig& config, float r0, bool r0Calibrated) {
  StoredConfig stored;
  stored.magic = kMagic;
  stored.version = kVersion;
  stored.ingestIntervalSec = config.ingestIntervalSec;
  stored.heaterAuto = config.heaterAuto ? 1 : 0;
  stored.r0Calibrated = r0Calibrated ? 1 : 0;
  stored.tempMinC = config.tempMinC;
  stored.tempMaxC = config.tempMaxC;
  stored.hysteresisC = config.hysteresisC;
  stored.nh3MaturePpm = config.nh3MaturePpm;
  stored.matureHoldMin = config.matureHoldMin;
  stored.heaterMaxOnMin = config.heaterMaxOnMin;
  stored.valveMaxOpenMin = config.valveMaxOpenMin;
  stored.commandTtlSec = config.commandTtlSec;
  stored.r0 = r0;
  EEPROM.put(0, stored);
}

}  // namespace config_store
