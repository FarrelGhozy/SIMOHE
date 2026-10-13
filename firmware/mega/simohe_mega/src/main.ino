#include <Arduino.h>
#include <avr/wdt.h>
#include <string.h>

#include <simohe_core.h>

#include "actuators.h"
#include "bridge.h"
#include "config.h"
#include "config_store.h"
#include "sensors.h"

Sensors sensors;
Actuators actuators;
MegaBridge bridge;

simohe::HeaterConfig config;
simohe::ThermalState thermal;
simohe::ValveState valve;
simohe::MaturityState maturity;

uint32_t seq = 0;
uint32_t lastTelemetryMs = 0;
uint32_t lastModeSent = 0;
bool prevTempHighCutoff = false;

void handleCommand(const simohe::Command& command, uint32_t nowMs) {
  bool ok = true;
  if (strcmp(command.action, "valve_open") == 0) {
    simohe::valveApplyOpen(valve, nowMs);
  } else if (strcmp(command.action, "valve_close") == 0) {
    simohe::valveApplyClose(valve);
  } else if (strcmp(command.action, "heater_on") == 0) {
    // Clamp durasi agar perkalian menit->ms tak overflow dan sejalan
    // dengan batas safety (maks heaterMaxOnMin, maks global 1440).
    uint32_t minutes = command.durationMin;
    if (minutes < 1) {
      minutes = 1;
    }
    if (minutes > config.heaterMaxOnMin) {
      minutes = config.heaterMaxOnMin;
    }
    if (minutes > simohe::kMaxMinutes) {
      minutes = simohe::kMaxMinutes;
    }
    thermal.mode = simohe::HeaterMode::ForceOn;
    thermal.forceOnUntilMs = nowMs + minutes * 60000UL;
  } else if (strcmp(command.action, "heater_off") == 0) {
    thermal.mode = simohe::HeaterMode::ForceOff;
    thermal.forceOnUntilMs = 0;
  } else if (strcmp(command.action, "heater_auto") == 0) {
    thermal.mode = simohe::HeaterMode::Auto;
    thermal.forceOnUntilMs = 0;
  } else {
    ok = false;
  }
  bridge.sendAck(command.id, ok);
#if SIMOHE_DEBUG
  Serial.print(F("[cmd] "));
  Serial.print(command.action);
  Serial.println(ok ? F(" ok") : F(" bad"));
#endif
}

#if SIMOHE_DEBUG
void pollSerialCommand() {
  static char buffer[24];
  static size_t length = 0;
  while (Serial.available() > 0) {
    const char c = (char)Serial.read();
    if (c == '\n' || c == '\r') {
      buffer[length] = '\0';
      if (strcmp(buffer, "cal") == 0) {
        sensors.requestCalibration();
        Serial.println(F("[cal] kalibrasi ulang R0 dimulai (udara bersih)"));
      } else if (strcmp(buffer, "status") == 0) {
        Serial.print(F("[status] ds="));
        Serial.print(sensors.deviceCount());
        Serial.print(F(" r0="));
        Serial.print(sensors.r0());
        Serial.print(F(" r0cal="));
        Serial.println(sensors.r0Calibrated() ? 1 : 0);
      }
      length = 0;
    } else if (length < sizeof(buffer) - 1) {
      buffer[length++] = c;
    }
  }
}
#endif

void handleFrame(const simohe::IncomingFrame& frame) {
  switch (frame.kind) {
    case simohe::FrameKind::Command:
      handleCommand(frame.command, millis());
      break;
    case simohe::FrameKind::Config:
      if (frame.configValid) {
        // decodeLine sudah sanitize, tapi tolak bila masih di luar nalar
        // (mis. EEPROM/server korup) agar safety tidak dilonggarkan diam-diam.
        simohe::HeaterConfig incoming = frame.config;
        if (simohe::sanitizeHeaterConfig(incoming)) {
          config = incoming;
          config_store::saveIfChanged(config, sensors.r0(), sensors.r0Calibrated());
        } else {
#if SIMOHE_DEBUG
          Serial.println(F("[config] ditolak/di-clamp (nilai liar)"));
#endif
          config = incoming;
          config_store::saveIfChanged(config, sensors.r0(), sensors.r0Calibrated());
        }
      }
      break;
    case simohe::FrameKind::Ping: {
      simohe::Telemetry telemetry;
      telemetry.seq = ++seq;  // monoton, tidak dipakai ulang
      telemetry.uptimeSec = millis() / 1000;
      telemetry.tempC = sensors.tempC();
      telemetry.nh3Ppm = sensors.nh3Ppm();
      telemetry.tempOk = sensors.tempOk();
      telemetry.nh3Ok = sensors.nh3Ok();
      telemetry.heater = actuators.heaterOn();
      telemetry.valve = actuators.valveOn();
      telemetry.mode = thermal.mode;
      telemetry.mature = maturity.mature;
      bridge.sendTelemetry(telemetry);
      break;
    }
    default:
      break;
  }
}

void setup() {
  wdt_disable();
  Serial.begin(SERIAL_BAUD);
  SIMOHE_ESP_SERIAL.begin(SERIAL_BAUD);
  bridge.begin(SIMOHE_ESP_SERIAL);
#if SIMOHE_DEBUG
  Serial.println(F("SIMOHE mega boot"));
#endif

  float r0 = -1.0f;
  bool r0Calibrated = false;
  if (!config_store::load(config, r0, r0Calibrated)) {
    simohe::sanitizeHeaterConfig(config);
    config_store::save(config, r0, r0Calibrated);
  } else {
    // Validasi hasil EEPROM (anti bit-flip / tulis parsial).
    simohe::sanitizeHeaterConfig(config);
    if (r0Calibrated && !(r0 > 0.0f && r0 < 1000.0f)) {
      r0 = -1.0f;
      r0Calibrated = false;
    }
  }

  sensors.begin();
  sensors.setR0(r0, r0Calibrated);
  actuators.begin();

  wdt_enable(WDTO_8S);
}

void loop() {
  wdt_reset();
  const uint32_t now = millis();

  sensors.update(now);
  if (sensors.calibrationDirty()) {
    sensors.clearCalibrationDirty();
    config_store::saveIfChanged(config, sensors.r0(), sensors.r0Calibrated());
  }

  simohe::thermalStep(thermal, config, sensors.tempOk(), sensors.tempC(), now);
  simohe::valveStep(valve, config, now);
  simohe::maturityStep(maturity, config, sensors.nh3Ok(), sensors.nh3Ppm(), now);

  actuators.apply(thermal.heater, valve.open);

#if SIMOHE_DEBUG
  pollSerialCommand();
#endif

  simohe::IncomingFrame frame;
  if (bridge.receiveWait(frame)) {
    handleFrame(frame);
  }

  // Edge-trigger: kirim SAFETY_CUTOFF hanya saat transisi, bukan tiap loop.
  // temp_high: tahan selama suhu >= tempMax, jadi butuh flag tepi sendiri.
  // heater_max_on & valve: sudah satu-shot dari state machine.
  const bool tempHighNow = thermal.safetyCutoff && thermal.safetyReason != nullptr &&
                           strcmp(thermal.safetyReason, "temp_high") == 0;
  if (thermal.safetyCutoff) {
    const bool isTempHigh = tempHighNow;
    if (!isTempHigh || !prevTempHighCutoff) {
      bridge.sendEvent("SAFETY_CUTOFF", thermal.safetyReason == nullptr ? "unknown" : thermal.safetyReason);
    }
  }
  prevTempHighCutoff = tempHighNow;
  if (valve.safetyClosed) {
    bridge.sendEvent("SAFETY_CUTOFF", "valve_max_open");
  }

  const bool due = (now - lastTelemetryMs) >= TELEMETRY_INTERVAL_MS;
  const bool changed = thermal.heaterChanged || valve.changed || maturity.justMatured ||
                       (uint32_t)thermal.mode != lastModeSent;
  if (due || changed) {
    simohe::Telemetry telemetry;
    telemetry.seq = ++seq;
    telemetry.uptimeSec = now / 1000;
    telemetry.tempC = sensors.tempC();
    telemetry.nh3Ppm = sensors.nh3Ppm();
    telemetry.tempOk = sensors.tempOk();
    telemetry.nh3Ok = sensors.nh3Ok();
    telemetry.heater = actuators.heaterOn();
    telemetry.valve = actuators.valveOn();
    telemetry.mode = thermal.mode;
    telemetry.mature = maturity.mature;
    bridge.sendTelemetry(telemetry);

    lastTelemetryMs = now;
    lastModeSent = (uint32_t)thermal.mode;
    thermal.heaterChanged = false;
    valve.changed = false;
  }
}
