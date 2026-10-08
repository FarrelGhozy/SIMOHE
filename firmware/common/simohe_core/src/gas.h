#pragma once

#include <stdint.h>

namespace simohe {

class MovingAverage {
 public:
  MovingAverage(float* buffer, uint8_t capacity);

  float push(float sample);
  float value() const;
  void reset();

  bool filled() const { return count_ == capacity_ && capacity_ > 0; }
  uint8_t count() const { return count_; }

 private:
  float* buffer_;
  uint8_t capacity_;
  uint8_t count_;
  uint8_t index_;
  float sum_;
};

float rsFromVoltage(float vOut, float vcc, float rl);
float r0FromCleanAir(float rsClean, float ratioClean);
float ppmFromRs(float rs, float r0, float a, float b);

}  // namespace simohe
