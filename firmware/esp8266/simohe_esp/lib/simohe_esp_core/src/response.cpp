#include "response.h"

#include <ArduinoJson.h>
#include <string.h>

namespace simohe_esp {

namespace {

bool copyString(char* destination, size_t capacity, const char* source) {
  return simohe::safeCopy(destination, capacity, source);
}

bool parseHeaterAuto(JsonVariant value, bool current) {
  if (value.isNull()) {
    return current;
  }
  if (value.is<bool>()) {
    return value.as<bool>();
  }
  return value.as<int>() != 0;
}

}  // namespace

bool parseIngestResponse(const char* json, IngestResult& out) {
  const simohe::HeaterConfig base = out.config;
  out.valid = false;
  out.commandCount = 0;
  if (json == nullptr) {
    out.config = base;
    return false;
  }

  StaticJsonDocument<1536> doc;
  if (deserializeJson(doc, json)) {
    out.config = base;
    return false;
  }
  if (!doc.containsKey("config")) {
    out.config = base;
    return false;
  }

  // Merge ke config berjalan (bukan default) agar field yang hilang dari
  // server tidak me-reset ambang ke default diam-diam.
  simohe::HeaterConfig merged = base;
  JsonObject config = doc["config"];
  merged.ingestIntervalSec = config["ingest_interval_sec"] | merged.ingestIntervalSec;
  merged.tempMinC = config["temp_min_c"] | merged.tempMinC;
  merged.tempMaxC = config["temp_max_c"] | merged.tempMaxC;
  merged.hysteresisC = config["temp_hysteresis_c"] | merged.hysteresisC;
  merged.nh3MaturePpm = config["nh3_mature_ppm"] | merged.nh3MaturePpm;
  merged.matureHoldMin = config["mature_hold_min"] | merged.matureHoldMin;
  merged.heaterAuto = parseHeaterAuto(config["heater_auto"], merged.heaterAuto);
  merged.heaterMaxOnMin = config["heater_max_on_min"] | merged.heaterMaxOnMin;
  merged.valveMaxOpenMin = config["valve_max_open_min"] | merged.valveMaxOpenMin;
  merged.commandTtlSec = config["command_ttl_sec"] | merged.commandTtlSec;
  simohe::sanitizeHeaterConfig(merged);
  out.config = merged;

  out.pollAfterSec = doc["poll_after_sec"] | 0;
  copyString(out.serverTime, sizeof(out.serverTime), doc["server_time"] | "");

  JsonArray commands = doc["commands"].as<JsonArray>();
  for (JsonObject command : commands) {
    if (out.commandCount >= kMaxCommands) {
      break;
    }
    const char* rawId = command["id"] | "";
    const char* rawAction = command["action"] | "";
    if (rawId[0] == '\0' || rawAction[0] == '\0') {
      continue;  // lewati perintah tanpa id/action
    }
    ServerCommand& target = out.commands[out.commandCount];
    if (!copyString(target.id, sizeof(target.id), rawId) ||
        !copyString(target.action, sizeof(target.action), rawAction)) {
      continue;  // terpotong -> lewati agar ack tetap cocok
    }
    int duration = command["args"]["duration_min"] | 30;
    if (duration < 1) {
      duration = 1;
    } else if (duration > (int)simohe::kMaxMinutes) {
      duration = (int)simohe::kMaxMinutes;
    }
    target.durationMin = (uint32_t)duration;
    const char* expires = command["expires_at"] | "";
    uint32_t epoch = simohe::parseIso8601Utc(expires);
    if (epoch == 0) {
      epoch = command["expires_epoch"] | 0;
    }
    target.hasExpiry = epoch != 0;
    target.expiresAtEpoch = epoch;
    out.commandCount++;
  }

  out.valid = true;
  return true;
}

}  // namespace simohe_esp
