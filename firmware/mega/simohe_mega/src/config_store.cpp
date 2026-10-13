#include "config_store.h"

#include <EEPROM.h>
#include <string.h>

namespace config_store {

namespace {

constexpr uint16_t kMagic = 0x5348;  // 'S''H'
constexpr uint16_t kVersion = 2;     // v2 tambah CRC (v1 tetap dibaca lalu di-upgrade)

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
  uint16_t crc;
};

uint16_t crc16(const uint8_t* data, size_t length) {
  uint16_t crc = 0xFFFF;
  for (size_t i = 0; i < length; i++) {
    crc ^= data[i];
    for (uint8_t b = 0; b < 8; b++) {
      crc = (crc & 1) ? (uint16_t)((crc >> 1) ^ 0xA001) : (uint16_t)(crc >> 1);
    }
  }
  return crc;
}

uint16_t storedCrc(const StoredConfig& stored) {
  StoredConfig tmp = stored;
  tmp.crc = 0;
  return crc16(reinterpret_cast<const uint8_t*>(&tmp), sizeof(tmp));
}

void toStored(const simohe::HeaterConfig& config, float r0, bool r0Calibrated, StoredConfig& out) {
  memset(&out, 0, sizeof(out));
  out.magic = kMagic;
  out.version = kVersion;
  out.ingestIntervalSec = config.ingestIntervalSec;
  out.heaterAuto = config.heaterAuto ? 1 : 0;
  out.r0Calibrated = r0Calibrated ? 1 : 0;
  out.tempMinC = config.tempMinC;
  out.tempMaxC = config.tempMaxC;
  out.hysteresisC = config.hysteresisC;
  out.nh3MaturePpm = config.nh3MaturePpm;
  out.matureHoldMin = config.matureHoldMin;
  out.heaterMaxOnMin = config.heaterMaxOnMin;
  out.valveMaxOpenMin = config.valveMaxOpenMin;
  out.commandTtlSec = config.commandTtlSec;
  out.r0 = r0;
  out.crc = 0;
  out.crc = crc16(reinterpret_cast<const uint8_t*>(&out), sizeof(out));
}

bool storedEqual(const StoredConfig& a, const StoredConfig& b) {
  return memcmp(&a, &b, sizeof(a)) == 0;
}

}  // namespace

bool load(simohe::HeaterConfig& config, float& r0, bool& r0Calibrated) {
  StoredConfig stored;
  EEPROM.get(0, stored);
  if (stored.magic != kMagic) {
    r0 = -1.0f;
    r0Calibrated = false;
    return false;
  }
  if (stored.version == 1) {
    // v1 tanpa CRC: terima lalu biarkan caller sanitize + save ulang ke v2.
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
  if (stored.version != kVersion) {
    r0 = -1.0f;
    r0Calibrated = false;
    return false;
  }
  if (storedCrc(stored) != stored.crc) {
    r0 = -1.0f;
    r0Calibrated = false;
    return false;  // korup: pakai default
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
  toStored(config, r0, r0Calibrated, stored);
  EEPROM.put(0, stored);
}

void saveIfChanged(const simohe::HeaterConfig& config, float r0, bool r0Calibrated) {
  StoredConfig current;
  EEPROM.get(0, current);
  StoredConfig next;
  toStored(config, r0, r0Calibrated, next);
  if (!storedEqual(current, next)) {
    EEPROM.put(0, next);
  }
}

}  // namespace config_store
