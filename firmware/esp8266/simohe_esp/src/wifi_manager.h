#pragma once

#include <Arduino.h>

class WifiManager {
 public:
  void begin();
  void loop(uint32_t nowMs);

  bool connected() const { return connected_; }

 private:
  bool connected_ = false;
  uint8_t attempt_ = 0;
  uint32_t nextAttemptMs_ = 0;
};
