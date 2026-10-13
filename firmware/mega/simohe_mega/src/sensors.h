#pragma once

#include <DallasTemperature.h>
#include <OneWire.h>

#include <simohe_core.h>

#include "config.h"

class Sensors {
 public:
  Sensors();

  void begin();
  void update(uint32_t nowMs);

  bool tempOk() const { return tempOk_; }
  float tempC() const { return tempC_; }
  bool nh3Ok() const { return nh3Ok_; }
  float nh3Ppm() const { return nh3Ppm_; }

  void setR0(float r0, bool calibrated);
  float r0() const { return r0_; }
  bool r0Calibrated() const { return r0Calibrated_; }

  uint8_t deviceCount() const { return deviceCount_; }
  bool calibrationDirty() const { return calibrationDirty_; }
  void clearCalibrationDirty() { calibrationDirty_ = false; }
  void requestCalibration();

 private:
  void updateTemperature(uint32_t nowMs);
  void updateGas(uint32_t nowMs);
  void scanBus();

  OneWire oneWire_;
  DallasTemperature dallas_;
  float tempBuffer_[TEMP_FILTER_SIZE];
  simohe::MovingAverage tempFilter_;
  float ppmBuffer_[PPM_FILTER_SIZE];
  simohe::MovingAverage ppmFilter_;

  float tempC_;
  bool tempOk_;
  float nh3Ppm_;
  bool nh3Ok_;
  float r0_;
  bool r0Calibrated_;

  uint32_t lastRequestMs_;
  bool conversionPending_;
  uint32_t conversionStartMs_;
  uint32_t lastGasMs_;
  uint32_t lastRescanMs_;
  uint8_t deviceCount_;

  bool calibrationDirty_;
  uint32_t gasStartMs_;
  float calRsSum_;
  float calRsMin_;
  float calRsMax_;
  uint16_t calSamples_;
};
