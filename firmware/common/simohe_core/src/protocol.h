#pragma once

#include <stddef.h>
#include <stdint.h>

namespace simohe {

constexpr uint16_t kFirmwareVersionMajor = 0;
constexpr uint16_t kFirmwareVersionMinor = 1;
constexpr uint16_t kFirmwareVersionPatch = 0;

constexpr size_t kMaxLine = 512;
constexpr size_t kMaxIdLen = 37;
constexpr size_t kMaxActionLen = 16;
constexpr size_t kMaxEventCodeLen = 24;
constexpr size_t kMaxEventDetailLen = 64;
constexpr size_t kMaxPendingCommands = 4;

enum class HeaterMode : uint8_t { Auto, ForceOn, ForceOff };

enum class FrameKind : uint8_t {
  None,
  Telemetry,
  Event,
  Ack,
  Command,
  Config,
  Ping,
  Unknown,
};

struct HeaterConfig {
  uint16_t ingestIntervalSec = 10;
  float tempMinC = 30.0f;
  float tempMaxC = 45.0f;
  float hysteresisC = 2.0f;
  float nh3MaturePpm = 25.0f;
  uint32_t matureHoldMin = 30;
  uint32_t heaterMaxOnMin = 60;
  uint32_t valveMaxOpenMin = 10;
  uint32_t commandTtlSec = 60;
  bool heaterAuto = true;
};

struct Telemetry {
  uint32_t seq = 0;
  uint32_t uptimeSec = 0;
  float tempC = 0.0f;
  float nh3Ppm = 0.0f;
  bool tempOk = false;
  bool nh3Ok = false;
  bool heater = false;
  bool valve = false;
  HeaterMode mode = HeaterMode::Auto;
  bool mature = false;
};

struct Command {
  char id[kMaxIdLen] = {0};
  char action[kMaxActionLen] = {0};
  uint32_t durationMin = 30;
  bool hasExpiry = false;
  uint32_t expiresAtEpoch = 0;
};

struct IncomingFrame {
  FrameKind kind = FrameKind::None;
  Telemetry telemetry;
  char eventCode[kMaxEventCodeLen] = {0};
  char eventDetail[kMaxEventDetailLen] = {0};
  char ackId[kMaxIdLen] = {0};
  bool ackOk = false;
  Command command;
  HeaterConfig config;
  bool configValid = false;
};

const char* modeToString(HeaterMode mode);
bool modeFromString(const char* text, HeaterMode& out);

}  // namespace simohe
