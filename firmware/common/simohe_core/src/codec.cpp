#include "codec.h"

#include <ArduinoJson.h>
#include <string.h>

#include "time_parse.h"

namespace simohe {

namespace {

size_t finish(JsonDocument& doc, char* out, size_t outSize) {
  size_t written = serializeJson(doc, out, outSize);
  if (written == 0 || written + 2 > outSize) {
    return 0;
  }
  out[written] = '\n';
  out[written + 1] = '\0';
  return written + 1;
}

bool copyString(char* destination, size_t capacity, const char* source) {
  if (source == nullptr) {
    destination[0] = '\0';
    return false;
  }
  strncpy(destination, source, capacity - 1);
  destination[capacity - 1] = '\0';
  return true;
}

}  // namespace

size_t encodeTelemetry(const Telemetry& telemetry, char* out, size_t outSize) {
  StaticJsonDocument<384> doc;
  doc["type"] = "telemetry";
  doc["seq"] = telemetry.seq;
  doc["uptime"] = telemetry.uptimeSec;
  if (telemetry.tempOk) {
    doc["temp_c"] = telemetry.tempC;
  } else {
    doc["temp_c"] = nullptr;
  }
  if (telemetry.nh3Ok) {
    doc["nh3_ppm"] = telemetry.nh3Ppm;
  } else {
    doc["nh3_ppm"] = nullptr;
  }
  doc["temp_ok"] = telemetry.tempOk;
  doc["nh3_ok"] = telemetry.nh3Ok;
  doc["heater"] = telemetry.heater;
  doc["valve"] = telemetry.valve;
  doc["mode"] = modeToString(telemetry.mode);
  doc["mature"] = telemetry.mature;
  return finish(doc, out, outSize);
}

size_t encodeEvent(const char* code, const char* detail, char* out, size_t outSize) {
  StaticJsonDocument<192> doc;
  doc["type"] = "event";
  doc["code"] = code;
  if (detail != nullptr && detail[0] != '\0') {
    doc["detail"] = detail;
  }
  return finish(doc, out, outSize);
}

size_t encodeAck(const char* id, bool ok, char* out, size_t outSize) {
  StaticJsonDocument<160> doc;
  doc["type"] = "ack";
  doc["id"] = id;
  doc["ok"] = ok;
  return finish(doc, out, outSize);
}

size_t encodeCommand(const Command& command, char* out, size_t outSize) {
  StaticJsonDocument<256> doc;
  doc["type"] = "cmd";
  doc["id"] = command.id;
  doc["action"] = command.action;
  JsonObject args = doc.createNestedObject("args");
  if (strcmp(command.action, "heater_on") == 0) {
    args["duration_min"] = command.durationMin;
  }
  if (command.hasExpiry) {
    doc["expires_epoch"] = command.expiresAtEpoch;
  }
  return finish(doc, out, outSize);
}

size_t encodeConfig(const HeaterConfig& config, char* out, size_t outSize) {
  StaticJsonDocument<384> doc;
  doc["type"] = "config";
  doc["ingest_interval_sec"] = config.ingestIntervalSec;
  doc["temp_min_c"] = config.tempMinC;
  doc["temp_max_c"] = config.tempMaxC;
  doc["temp_hysteresis_c"] = config.hysteresisC;
  doc["nh3_mature_ppm"] = config.nh3MaturePpm;
  doc["mature_hold_min"] = config.matureHoldMin;
  doc["heater_auto"] = config.heaterAuto ? 1 : 0;
  doc["heater_max_on_min"] = config.heaterMaxOnMin;
  doc["valve_max_open_min"] = config.valveMaxOpenMin;
  doc["command_ttl_sec"] = config.commandTtlSec;
  return finish(doc, out, outSize);
}

size_t encodePing(char* out, size_t outSize) {
  StaticJsonDocument<96> doc;
  doc["type"] = "ping";
  return finish(doc, out, outSize);
}

bool decodeLine(const char* line, IncomingFrame& out) {
  if (line == nullptr) {
    return false;
  }

  StaticJsonDocument<640> doc;
  if (deserializeJson(doc, line)) {
    return false;
  }

  const char* type = doc["type"] | "";
  if (strcmp(type, "telemetry") == 0) {
    out.kind = FrameKind::Telemetry;
    out.telemetry.seq = doc["seq"] | 0;
    out.telemetry.uptimeSec = doc["uptime"] | 0;
    if (!doc["temp_c"].isNull()) {
      out.telemetry.tempC = doc["temp_c"].as<float>();
      out.telemetry.tempOk = true;
    } else {
      out.telemetry.tempOk = false;
    }
    if (!doc["nh3_ppm"].isNull()) {
      out.telemetry.nh3Ppm = doc["nh3_ppm"].as<float>();
      out.telemetry.nh3Ok = true;
    } else {
      out.telemetry.nh3Ok = false;
    }
    if (doc.containsKey("temp_ok")) {
      out.telemetry.tempOk = doc["temp_ok"].as<bool>();
    }
    if (doc.containsKey("nh3_ok")) {
      out.telemetry.nh3Ok = doc["nh3_ok"].as<bool>();
    }
    out.telemetry.heater = doc["heater"] | false;
    out.telemetry.valve = doc["valve"] | false;
    out.telemetry.mature = doc["mature"] | false;
    HeaterMode mode = HeaterMode::Auto;
    const char* modeText = doc["mode"] | "AUTO";
    modeFromString(modeText, mode);
    out.telemetry.mode = mode;
    return true;
  }

  if (strcmp(type, "event") == 0) {
    out.kind = FrameKind::Event;
    copyString(out.eventCode, sizeof(out.eventCode), doc["code"] | "");
    copyString(out.eventDetail, sizeof(out.eventDetail), doc["detail"] | "");
    return true;
  }

  if (strcmp(type, "ack") == 0) {
    out.kind = FrameKind::Ack;
    copyString(out.ackId, sizeof(out.ackId), doc["id"] | "");
    out.ackOk = doc["ok"] | false;
    return true;
  }

  if (strcmp(type, "cmd") == 0) {
    out.kind = FrameKind::Command;
    copyString(out.command.id, sizeof(out.command.id), doc["id"] | "");
    copyString(out.command.action, sizeof(out.command.action), doc["action"] | "");
    out.command.durationMin = doc["args"]["duration_min"] | 30;
    const char* expires = doc["expires_at"] | "";
    uint32_t epoch = parseIso8601Utc(expires);
    if (epoch == 0) {
      epoch = doc["expires_epoch"] | 0;
    }
    out.command.hasExpiry = epoch != 0;
    out.command.expiresAtEpoch = epoch;
    return true;
  }

  if (strcmp(type, "config") == 0) {
    out.kind = FrameKind::Config;
    HeaterConfig config;
    config.ingestIntervalSec = doc["ingest_interval_sec"] | config.ingestIntervalSec;
    config.tempMinC = doc["temp_min_c"] | config.tempMinC;
    config.tempMaxC = doc["temp_max_c"] | config.tempMaxC;
    config.hysteresisC = doc["temp_hysteresis_c"] | config.hysteresisC;
    config.nh3MaturePpm = doc["nh3_mature_ppm"] | config.nh3MaturePpm;
    config.matureHoldMin = doc["mature_hold_min"] | config.matureHoldMin;
    bool heaterAuto = config.heaterAuto;
    if (doc.containsKey("heater_auto")) {
      heaterAuto = doc["heater_auto"].as<int>() != 0;
    }
    config.heaterAuto = heaterAuto;
    config.heaterMaxOnMin = doc["heater_max_on_min"] | config.heaterMaxOnMin;
    config.valveMaxOpenMin = doc["valve_max_open_min"] | config.valveMaxOpenMin;
    config.commandTtlSec = doc["command_ttl_sec"] | config.commandTtlSec;
    out.config = config;
    out.configValid = true;
    return true;
  }

  if (strcmp(type, "ping") == 0) {
    out.kind = FrameKind::Ping;
    return true;
  }

  out.kind = FrameKind::Unknown;
  return true;
}

}  // namespace simohe
