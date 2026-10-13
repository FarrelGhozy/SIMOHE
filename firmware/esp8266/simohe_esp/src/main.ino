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
simohe::HeaterConfig lastSentConfig;
bool haveSentConfig = false;

bool configEquals(const simohe::HeaterConfig& a, const simohe::HeaterConfig& b) {
  const float eps = 0.001f;
  const bool floatsEqual = fabsf(a.tempMinC - b.tempMinC) < eps &&
                           fabsf(a.tempMaxC - b.tempMaxC) < eps &&
                           fabsf(a.hysteresisC - b.hysteresisC) < eps &&
                           fabsf(a.nh3MaturePpm - b.nh3MaturePpm) < eps;
  return a.ingestIntervalSec == b.ingestIntervalSec && floatsEqual &&
         a.matureHoldMin == b.matureHoldMin && a.heaterMaxOnMin == b.heaterMaxOnMin &&
         a.valveMaxOpenMin == b.valveMaxOpenMin && a.commandTtlSec == b.commandTtlSec &&
         a.heaterAuto == b.heaterAuto;
}

void sendConfigIfChanged() {
  if (!haveSentConfig || !configEquals(config, lastSentConfig)) {
    bridge.sendConfig(config);
    lastSentConfig = config;
    haveSentConfig = true;
  }
}

uint32_t serverEpoch = 0;
uint32_t serverEpochAtMs = 0;
bool timeSynced = false;

uint32_t nextIngestMs = 0;
uint32_t nextPingMs = PING_INTERVAL_MS;
uint32_t ingestBackoffAttempt = 0;
bool ledState = false;

char ingestBody[900];
char responseBuffer[1400];
static_assert(OFFLINE_FRAME_SIZE >= 900,
              "OFFLINE_FRAME_SIZE harus muat satu body ingest utuh");

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
  if (code == nullptr) {
    return;
  }
  PendingEvent& target = pendingEvents[pendingEventCount];
  simohe::safeCopy(target.code, sizeof(target.code), code);
  simohe::safeCopy(target.detail, sizeof(target.detail), detail);
  pendingEventCount++;
}

void addAck(const char* id, bool ok) {
  if (pendingAckCount >= kMaxPendingAcks) {
    return;
  }
  if (id == nullptr || id[0] == '\0') {
    return;
  }
  PendingAck& target = pendingAcks[pendingAckCount];
  if (!simohe::safeCopy(target.id, sizeof(target.id), id)) {
    return;  // terpotong -> jangan ack id rusak
  }
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
    if (command.hasExpiry && command.expiresAtEpoch != 0) {
      if (!timeSynced) {
        continue;  // belum sync waktu -> tunda perintah ber-expiry, jangan eksekusi buta
      }
      if (nowEpoch > command.expiresAtEpoch) {
        continue;
      }
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
  // Pending sudah tersalin ke ingestBody; bersihkan agar tak ganda.
  clearPending();

  if (!ok) {
    if (statusCode == 400) {
      // Payload ditolak server (bad request): jangan buffer, hindari poison queue.
      ingestBackoffAttempt = 0;
      nextIngestMs = nowMs + (config.ingestIntervalSec < 1 ? 1 : config.ingestIntervalSec) * 1000UL;
      return;
    }
    offline.push(ingestBody);
    ingestBackoffAttempt++;
    nextIngestMs = nowMs + simohe_esp::backoffDelayMs(ingestBackoffAttempt);
    return;
  }

  ingestBackoffAttempt = 0;
  simohe_esp::IngestResult result;
  result.config = config;  // merge: field hilang tidak reset ke default
  if (simohe_esp::parseIngestResponse(responseBuffer, result) && result.valid) {
    config = result.config;
    sendConfigIfChanged();
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
      if (statusCode == 400) {
        offline.pop();  // payload busuk: buang, jangan macetkan antrian
        continue;
      }
      break;
    }
    offline.pop();
    drained++;
  }
  // Replay offline hanya untuk pengiriman ulang telemetri. Config/waktu/
  // perintah dari respons replay sengaja TIDAK diterapkan (basi).
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

  if (simohe::timeReached(now, nextPingMs)) {
    bridge.sendPing();
    nextPingMs = now + PING_INTERVAL_MS;
  }

  if (simohe::timeReached(now, nextIngestMs)) {
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
