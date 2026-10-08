#include "response.h"

#include <ArduinoJson.h>
#include <string.h>

namespace simohe_esp {

namespace {

void copyString(char* destination, size_t capacity, const char* source) {
  if (source == nullptr) {
    destination[0] = '\0';
    return;
  }
  strncpy(destination, source, capacity - 1);
  destination[capacity - 1] = '\0';
}

}  // namespace

bool parseIngestResponse(const char* json, IngestResult& out) {
  out.valid = false;
  out.commandCount = 0;
  if (json == nullptr) {
    return false;
  }

  StaticJsonDocument<1024> doc;
  if (deserializeJson(doc, json)) {
    return false;
  }
  if (!doc.containsKey("config")) {
    return false;
  }

  JsonObject config = doc["config"];
  out.config.ingestIntervalSec = config["ingest_interval_sec"] | out.config.ingestIntervalSec;
  out.config.tempMinC = config["temp_min_c"] | out.config.tempMinC;
  out.config.tempMaxC = config["temp_max_c"] | out.config.tempMaxC;
  out.config.hysteresisC = config["temp_hysteresis_c"] | out.config.hysteresisC;
  out.config.nh3MaturePpm = config["nh3_mature_ppm"] | out.config.nh3MaturePpm;
  out.config.matureHoldMin = config["mature_hold_min"] | out.config.matureHoldMin;
  if (config.containsKey("heater_auto")) {
    out.config.heaterAuto = config["heater_auto"].as<int>() != 0;
  }
  out.config.heaterMaxOnMin = config["heater_max_on_min"] | out.config.heaterMaxOnMin;
  out.config.valveMaxOpenMin = config["valve_max_open_min"] | out.config.valveMaxOpenMin;
  out.config.commandTtlSec = config["command_ttl_sec"] | out.config.commandTtlSec;

  out.pollAfterSec = doc["poll_after_sec"] | 0;
  copyString(out.serverTime, sizeof(out.serverTime), doc["server_time"] | "");

  JsonArray commands = doc["commands"].as<JsonArray>();
  for (JsonObject command : commands) {
    if (out.commandCount >= kMaxCommands) {
      break;
    }
    ServerCommand& target = out.commands[out.commandCount];
    copyString(target.id, sizeof(target.id), command["id"] | "");
    copyString(target.action, sizeof(target.action), command["action"] | "");
    target.durationMin = command["args"]["duration_min"] | 30;
    const char* expires = command["expires_at"] | "";
    uint32_t epoch = simohe::parseIso8601Utc(expires);
    target.hasExpiry = epoch != 0;
    target.expiresAtEpoch = epoch;
    out.commandCount++;
  }

  out.valid = true;
  return true;
}

}  // namespace simohe_esp
