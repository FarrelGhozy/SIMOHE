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

void handleCommand(const simohe::Command& command, uint32_t nowMs) {
  bool ok = true;
  if (strcmp(command.action, "valve_open") == 0) {
    simohe::valveApplyOpen(valve, nowMs);
  } else if (strcmp(command.action, "valve_close") == 0) {
    simohe::valveApplyClose(valve);
  } else if (strcmp(command.action, "heater_on") == 0) {
    thermal.mode = simohe::HeaterMode::ForceOn;
    thermal.forceOnUntilMs = nowMs + command.durationMin * 60000UL;
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
}

void handleFrame(const simohe::IncomingFrame& frame) {
  switch (frame.kind) {
    case simohe::FrameKind::Command:
      handleCommand(frame.command, millis());
      break;
    case simohe::FrameKind::Config:
      if (frame.configValid) {
        config = frame.config;
        config_store::save(config, sensors.r0(), sensors.r0Calibrated());
      }
      break;
    case simohe::FrameKind::Ping: {
      simohe::Telemetry telemetry;
      telemetry.seq = seq;
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

  float r0 = -1.0f;
  bool r0Calibrated = false;
  if (!config_store::load(config, r0, r0Calibrated)) {
    config_store::save(config, r0, r0Calibrated);
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
  simohe::thermalStep(thermal, config, sensors.tempOk(), sensors.tempC(), now);
  simohe::valveStep(valve, config, now);
  simohe::maturityStep(maturity, config, sensors.nh3Ok(), sensors.nh3Ppm(), now);

  if (thermal.mode == simohe::HeaterMode::Auto && !config.heaterAuto) {
    thermal.heater = false;
  }

  actuators.apply(thermal.heater, valve.open);

  simohe::IncomingFrame frame;
  if (bridge.receiveWait(frame)) {
    handleFrame(frame);
  }

  if (thermal.safetyCutoff) {
    bridge.sendEvent("SAFETY_CUTOFF", thermal.safetyReason == nullptr ? "unknown" : thermal.safetyReason);
  }
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
