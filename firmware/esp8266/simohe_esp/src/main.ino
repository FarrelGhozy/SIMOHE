#include <Arduino.h>
#include <simohe_core.h>
#include <simohe_esp_core.h>
#include <string.h>

#include "api_client.h"
#include "config.h"
#include "serial_bridge.h"
#include "wifi_manager.h"

WifiManager wifi;
EspBridge bridge;
ApiClient api;

char offlineStorage[OFFLINE_FRAME_SIZE * OFFLINE_CAPACITY];
simohe_esp::OfflineBuffer offline(offlineStorage, OFFLINE_FRAME_SIZE, OFFLINE_CAPACITY);

struct PendingEvent {
  char code[simohe::kMaxEventCodeLen];
  char detail[simohe::kMaxEventDetailLen];
};
struct PendingAck {
  char id[simohe::kMaxIdLen];
  bool ok;
};

constexpr size_t kMaxPendingEvents = 8;
constexpr size_t kMaxPendingAcks = 8;

PendingEvent pendingEvents[kMaxPendingEvents];
size_t pendingEventCount = 0;
PendingAck pendingAcks[kMaxPendingAcks];
size_t pendingAckCount = 0;

simohe::Telemetry latestTelemetry;
bool haveTelemetry = false;
simohe::HeaterConfig config;

uint32_t serverEpoch = 0;
uint32_t serverEpochAtMs = 0;
bool timeSynced = false;

uint32_t nextIngestMs = 0;
uint32_t nextPingMs = PING_INTERVAL_MS;
uint32_t ingestBackoffAttempt = 0;
bool ledState = false;

char ingestBody[900];
char responseBuffer[1400];

uint32_t currentEpoch() {
  if (!timeSynced) {
    return 0;
  }
  return serverEpoch + (millis() - serverEpochAtMs) / 1000UL;
}

void syncTime(const char* iso) {
  const uint32_t epoch = simohe::parseIso8601Utc(iso);
  if (epoch != 0) {
    serverEpoch = epoch;
    serverEpochAtMs = millis();
    timeSynced = true;
  }
}

void setLed(bool on) {
  if (on == ledState) {
    return;
  }
  const uint8_t level = STATUS_LED_ACTIVE_LOW ? (on ? LOW : HIGH) : (on ? HIGH : LOW);
  digitalWrite(PIN_STATUS_LED, level);
  ledState = on;
}

void addEvent(const char* code, const char* detail) {
  if (pendingEventCount >= kMaxPendingEvents) {
    return;
  }
  PendingEvent& target = pendingEvents[pendingEventCount];
  strncpy(target.code, code, sizeof(target.code) - 1);
  target.code[sizeof(target.code) - 1] = '\0';
  strncpy(target.detail, detail, sizeof(target.detail) - 1);
  target.detail[sizeof(target.detail) - 1] = '\0';
  pendingEventCount++;
}

void addAck(const char* id, bool ok) {
  if (pendingAckCount >= kMaxPendingAcks) {
    return;
  }
  PendingAck& target = pendingAcks[pendingAckCount];
  strncpy(target.id, id, sizeof(target.id) - 1);
  target.id[sizeof(target.id) - 1] = '\0';
  target.ok = ok;
  pendingAckCount++;
}

void handleIncoming(const simohe::IncomingFrame& frame) {
  switch (frame.kind) {
    case simohe::FrameKind::Telemetry:
      latestTelemetry = frame.telemetry;
      haveTelemetry = true;
      break;
    case simohe::FrameKind::Event:
      addEvent(frame.eventCode, frame.eventDetail);
      break;
    case simohe::FrameKind::Ack:
      addAck(frame.ackId, frame.ackOk);
      break;
    default:
      break;
  }
}

size_t composeBody() {
  if (!haveTelemetry) {
    return 0;
  }

  simohe_esp::EventItem events[kMaxPendingEvents];
  for (size_t i = 0; i < pendingEventCount; i++) {
    events[i].code = pendingEvents[i].code;
    events[i].detail = pendingEvents[i].detail;
  }
  simohe_esp::AckItem acks[kMaxPendingAcks];
  for (size_t i = 0; i < pendingAckCount; i++) {
    acks[i].id = pendingAcks[i].id;
    acks[i].ok = pendingAcks[i].ok;
  }

  char ts[24];
  ts[0] = '\0';
  simohe::formatIso8601Utc(currentEpoch(), ts, sizeof(ts));

  return simohe_esp::buildIngestBody(latestTelemetry, SIMOHE_FW_VERSION, ts, events,
                                     pendingEventCount, acks, pendingAckCount, ingestBody,
                                     sizeof(ingestBody));
}

void clearPending() {
  pendingEventCount = 0;
  pendingAckCount = 0;
}

void handleCommands(const simohe_esp::IngestResult& result) {
  const uint32_t nowEpoch = currentEpoch();
  for (size_t i = 0; i < result.commandCount; i++) {
    const simohe_esp::ServerCommand& command = result.commands[i];
    if (command.hasExpiry && nowEpoch != 0 && command.expiresAtEpoch != 0 &&
        nowEpoch > command.expiresAtEpoch) {
      continue;
    }
    bridge.sendCommand(command);
  }
}

void doIngest(uint32_t nowMs) {
  const size_t length = composeBody();
  if (length == 0) {
    nextIngestMs = nowMs + 1000;
    return;
  }

  int statusCode = 0;
  const bool ok = api.postIngest(ingestBody, responseBuffer, sizeof(responseBuffer), statusCode);
  clearPending();

  if (!ok) {
    offline.push(ingestBody);
    ingestBackoffAttempt++;
    nextIngestMs = nowMs + simohe_esp::backoffDelayMs(ingestBackoffAttempt);
    return;
  }

  ingestBackoffAttempt = 0;
  simohe_esp::IngestResult result;
  if (simohe_esp::parseIngestResponse(responseBuffer, result) && result.valid) {
    config = result.config;
    bridge.sendConfig(config);
    syncTime(result.serverTime);
    handleCommands(result);
    const uint32_t intervalSec = result.pollAfterSec > 0 ? result.pollAfterSec : config.ingestIntervalSec;
    nextIngestMs = nowMs + (intervalSec < 1 ? 1 : intervalSec) * 1000UL;
  } else {
    nextIngestMs = nowMs + (config.ingestIntervalSec < 1 ? 1 : config.ingestIntervalSec) * 1000UL;
  }
}

void enqueueCurrent(uint32_t nowMs) {
  const size_t length = composeBody();
  if (length > 0) {
    offline.push(ingestBody);
    clearPending();
  }
  nextIngestMs = nowMs + (config.ingestIntervalSec < 1 ? 1 : config.ingestIntervalSec) * 1000UL;
}

void drainOffline() {
  uint8_t drained = 0;
  while (drained < 5 && !offline.empty()) {
    int statusCode = 0;
    const bool ok = api.postIngest(offline.peek(), responseBuffer, sizeof(responseBuffer), statusCode);
    if (!ok) {
      break;
    }
    offline.pop();
    drained++;
  }
  if (drained > 0) {
    simohe_esp::IngestResult result;
    if (simohe_esp::parseIngestResponse(responseBuffer, result) && result.valid) {
      config = result.config;
      syncTime(result.serverTime);
    }
  }
}

void setup() {
  Serial.begin(ESP_SERIAL_BAUD);
  bridge.begin(Serial);

  pinMode(PIN_STATUS_LED, OUTPUT);
  setLed(false);

  wifi.begin();
}

void loop() {
  ESP.wdtFeed();
  const uint32_t now = millis();
  wifi.loop(now);

  simohe::IncomingFrame frame;
  while (bridge.receive(frame)) {
    handleIncoming(frame);
  }

  if (now >= nextPingMs) {
    bridge.sendPing();
    nextPingMs = now + PING_INTERVAL_MS;
  }

  if (now >= nextIngestMs) {
    if (wifi.connected()) {
      doIngest(now);
      drainOffline();
    } else if (haveTelemetry) {
      enqueueCurrent(now);
    } else {
      nextIngestMs = now + 1000;
    }
  }

  setLed(wifi.connected());
  delay(1);
}
