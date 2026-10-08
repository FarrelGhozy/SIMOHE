#include "sensors.h"

#include <math.h>

Sensors::Sensors()
    : oneWire_(PIN_ONEWIRE),
      dallas_(&oneWire_),
      tempFilter_(tempBuffer_, TEMP_FILTER_SIZE),
      tempC_(0.0f),
      tempOk_(false),
      nh3Ppm_(0.0f),
      nh3Ok_(false),
      r0_(-1.0f),
      r0Calibrated_(false),
      lastRequestMs_(0),
      conversionPending_(false),
      conversionStartMs_(0),
      lastGasMs_(0) {}

void Sensors::begin() {
  dallas_.begin();
  dallas_.setWaitForConversion(false);
  dallas_.requestTemperatures();
  conversionPending_ = true;
  conversionStartMs_ = millis();
}

void Sensors::setR0(float r0, bool calibrated) {
  r0_ = r0;
  r0Calibrated_ = calibrated;
}

void Sensors::update(uint32_t nowMs) {
  updateTemperature(nowMs);
  updateGas(nowMs);
}

void Sensors::updateTemperature(uint32_t nowMs) {
  if (conversionPending_ && (nowMs - conversionStartMs_) >= TEMP_CONVERSION_MS) {
    const float reading = dallas_.getTempCByIndex(0);
    const bool valid = reading != DEVICE_DISCONNECTED_C && reading > -55.0f && reading < 125.0f &&
                       !(reading > 84.9f && reading < 85.1f);
    if (valid) {
      tempC_ = tempFilter_.push(reading);
      tempOk_ = true;
    } else {
      tempOk_ = false;
    }
    conversionPending_ = false;
    lastRequestMs_ = nowMs;
  }

  if (!conversionPending_ && (nowMs - lastRequestMs_) >= SENSOR_INTERVAL_MS) {
    dallas_.requestTemperatures();
    conversionPending_ = true;
    conversionStartMs_ = nowMs;
  }
}

void Sensors::updateGas(uint32_t nowMs) {
  if (lastGasMs_ != 0 && (nowMs - lastGasMs_) < SENSOR_INTERVAL_MS) {
    return;
  }
  lastGasMs_ = nowMs;

  const int raw = analogRead(PIN_MQ137);
  const float voltage = (float)raw * MQ_VCC / 1023.0f;
  const float rs = simohe::rsFromVoltage(voltage, MQ_VCC, MQ_RL_KOHM);
  if (r0Calibrated_ && rs > 0.0f) {
    const float ppm = simohe::ppmFromRs(rs, r0_, MQ_CURVE_A, MQ_CURVE_B);
    if (ppm >= 0.0f) {
      nh3Ppm_ = ppm;
      nh3Ok_ = true;
      return;
    }
  }
  nh3Ok_ = false;
}
