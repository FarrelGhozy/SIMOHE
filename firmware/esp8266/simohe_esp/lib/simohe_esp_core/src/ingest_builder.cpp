#include "ingest_builder.h"

#include <ArduinoJson.h>

namespace simohe_esp {

size_t buildIngestBody(const simohe::Telemetry& telemetry, const char* firmware, const char* ts,
                       const EventItem* events, size_t eventCount, const AckItem* acks,
                       size_t ackCount, char* out, size_t outSize) {
  StaticJsonDocument<1024> doc;
  doc["seq"] = telemetry.seq;
  doc["firmware"] = firmware;
  doc["ts"] = ts;

  JsonObject telemetryObject = doc.createNestedObject("telemetry");
  if (telemetry.tempOk) {
    telemetryObject["temp_c"] = telemetry.tempC;
  } else {
    telemetryObject["temp_c"] = nullptr;
  }
  if (telemetry.nh3Ok) {
    telemetryObject["nh3_ppm"] = telemetry.nh3Ppm;
  } else {
    telemetryObject["nh3_ppm"] = nullptr;
  }
  telemetryObject["temp_ok"] = telemetry.tempOk;
  telemetryObject["heater"] = telemetry.heater;
  telemetryObject["valve"] = telemetry.valve;
  telemetryObject["mode"] = simohe::modeToString(telemetry.mode);
  telemetryObject["mature"] = telemetry.mature;
  telemetryObject["uptime"] = telemetry.uptimeSec;

  if (events != nullptr && eventCount > 0) {
    JsonArray eventArray = doc.createNestedArray("events");
    for (size_t i = 0; i < eventCount; i++) {
      JsonObject event = eventArray.createNestedObject();
      event["code"] = events[i].code;
      if (events[i].detail != nullptr && events[i].detail[0] != '\0') {
        event["detail"] = events[i].detail;
      }
    }
  }

  if (acks != nullptr && ackCount > 0) {
    JsonArray ackArray = doc.createNestedArray("acks");
    for (size_t i = 0; i < ackCount; i++) {
      JsonObject ack = ackArray.createNestedObject();
      ack["id"] = acks[i].id;
      ack["ok"] = acks[i].ok;
    }
  }

  const size_t written = serializeJson(doc, out, outSize);
  if (written == 0 || written >= outSize) {
    return 0;
  }
  return written;
}

}  // namespace simohe_esp
