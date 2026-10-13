#include "sensors.h"

#include <math.h>

Sensors::Sensors()
    : oneWire_(PIN_ONEWIRE),
      dallas_(&oneWire_),
      tempFilter_(tempBuffer_, TEMP_FILTER_SIZE),
      ppmFilter_(ppmBuffer_, PPM_FILTER_SIZE),
      tempC_(0.0f),
      tempOk_(false),
      nh3Ppm_(0.0f),
      nh3Ok_(false),
      r0_(-1.0f),
      r0Calibrated_(false),
      lastRequestMs_(0),
      conversionPending_(false),
      conversionStartMs_(0),
      lastGasMs_(0),
      lastRescanMs_(0),
      deviceCount_(0),
      calibrationDirty_(false),
      gasStartMs_(0),
      calRsSum_(0.0f),
      calRsMin_(0.0f),
      calRsMax_(0.0f),
      calSamples_(0) {}

void Sensors::begin() {
  const uint32_t now = millis();
  scanBus();
  lastRescanMs_ = now;
  gasStartMs_ = now;
  dallas_.setWaitForConversion(false);
  dallas_.requestTemperatures();
  conversionPending_ = true;
  conversionStartMs_ = now;
}

void Sensors::setR0(float r0, bool calibrated) {
  r0_ = r0;
  r0Calibrated_ = calibrated;
  ppmFilter_.reset();
}

void Sensors::requestCalibration() {
  r0_ = -1.0f;
  r0Calibrated_ = false;
  calibrationDirty_ = true;
  ppmFilter_.reset();
  gasStartMs_ = millis();
  calRsSum_ = 0.0f;
  calRsMin_ = 0.0f;
  calRsMax_ = 0.0f;
  calSamples_ = 0;
}

void Sensors::scanBus() {
  dallas_.begin();
  deviceCount_ = dallas_.getDeviceCount();
  if (deviceCount_ > 0) {
    dallas_.setResolution(12);
  }
#if SIMOHE_DEBUG
  Serial.print(F("[ds] devices="));
  Serial.println(deviceCount_);
#endif
}

void Sensors::update(uint32_t nowMs) {
  updateTemperature(nowMs);
  updateGas(nowMs);
}

void Sensors::updateTemperature(uint32_t nowMs) {
  if (deviceCount_ == 0 && (nowMs - lastRescanMs_) >= SENSOR_RESCAN_MS) {
    lastRescanMs_ = nowMs;
    scanBus();
  }

  if (conversionPending_ && (nowMs - conversionStartMs_) >= TEMP_CONVERSION_MS) {
    const float reading = deviceCount_ > 0 ? dallas_.getTempCByIndex(0) : DEVICE_DISCONNECTED_C;
    const bool valid = reading != DEVICE_DISCONNECTED_C && reading > -55.0f && reading < 125.0f &&
                       !(reading > 84.9f && reading < 85.1f);
    if (valid) {
      tempC_ = tempFilter_.push(reading);
      tempOk_ = true;
    } else {
      tempOk_ = false;
#if SIMOHE_DEBUG
      Serial.print(F("[ds] read fail raw="));
      Serial.println(reading);
#endif
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
#if SIMOHE_DEBUG
  Serial.print(F("[mq] raw="));
  Serial.print(raw);
  Serial.print(F(" rs="));
  Serial.println(rs);
#endif

  if (r0Calibrated_) {
    if (rs > 0.0f) {
      const float ppm = simohe::ppmFromRs(rs, r0_, MQ_CURVE_A, MQ_CURVE_B);
      if (ppm >= 0.0f && ppm <= 1000.0f) {
        nh3Ppm_ = ppmFilter_.push(ppm);
        nh3Ok_ = true;
        return;
      }
    }
    nh3Ok_ = false;
    return;
  }

  // Otomatis kalibrasi R0 sekali dari udara bersih setelah warmup.
  nh3Ok_ = false;
  if (gasStartMs_ == 0) {
    gasStartMs_ = nowMs;
  }
  if (rs <= 0.0f || (nowMs - gasStartMs_) < MQ_CAL_WARMUP_MS) {
    return;
  }

  if (calSamples_ == 0) {
    calRsMin_ = rs;
    calRsMax_ = rs;
  } else {
    if (rs < calRsMin_) calRsMin_ = rs;
    if (rs > calRsMax_) calRsMax_ = rs;
  }
  calRsSum_ += rs;
  calSamples_++;

  if (calSamples_ < MQ_CAL_SAMPLES) {
    return;
  }

  const float mean = calRsSum_ / (float)calSamples_;
  const bool stable = mean > 0.0f && (calRsMax_ - calRsMin_) <= MQ_CAL_MAX_SPREAD * mean;
  if (stable) {
    const float r0 = mean / MQ_RATIO_CLEAN;
    if (r0 > 0.0f) {
      r0_ = r0;
      r0Calibrated_ = true;
      calibrationDirty_ = true;
#if SIMOHE_DEBUG
      Serial.print(F("[mq] R0 calibrated="));
      Serial.println(r0_);
#endif
    }
  } else {
#if SIMOHE_DEBUG
    Serial.println(F("[mq] Rn tidak stabil, ulangi kalibrasi"));
#endif
  }

  // Reset akumulator; bila belum stabil akan dicoba lagi dari awal.
  calRsSum_ = 0.0f;
  calRsMin_ = 0.0f;
  calRsMax_ = 0.0f;
  calSamples_ = 0;
}
