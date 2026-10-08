#pragma once

#include <stdint.h>

#include "config.h"

class Actuators {
 public:
  void begin();
  void apply(bool heaterOn, bool valveOn);

  bool heaterOn() const { return heaterOn_; }
  bool valveOn() const { return valveOn_; }

 private:
  void writeRelay(uint8_t pin, bool on);

  bool heaterOn_ = false;
  bool valveOn_ = false;
};
