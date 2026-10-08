#include "gas.h"

#include <math.h>

namespace simohe {

MovingAverage::MovingAverage(float* buffer, uint8_t capacity)
    : buffer_(buffer), capacity_(capacity), count_(0), index_(0), sum_(0.0f) {}

float MovingAverage::push(float sample) {
  if (capacity_ == 0) {
    return sample;
  }
  if (count_ < capacity_) {
    buffer_[count_] = sample;
    sum_ += sample;
    count_++;
  } else {
    sum_ -= buffer_[index_];
    buffer_[index_] = sample;
    sum_ += sample;
    index_ = (uint8_t)((index_ + 1) % capacity_);
  }
  return value();
}

float MovingAverage::value() const {
  if (count_ == 0) {
    return 0.0f;
  }
  return sum_ / (float)count_;
}

void MovingAverage::reset() {
  count_ = 0;
  index_ = 0;
  sum_ = 0.0f;
}

float rsFromVoltage(float vOut, float vcc, float rl) {
  if (vOut <= 0.0f || vOut >= vcc) {
    return -1.0f;
  }
  return rl * (vcc - vOut) / vOut;
}

float r0FromCleanAir(float rsClean, float ratioClean) {
  if (rsClean <= 0.0f || ratioClean <= 0.0f) {
    return -1.0f;
  }
  return rsClean / ratioClean;
}

float ppmFromRs(float rs, float r0, float a, float b) {
  if (rs <= 0.0f || r0 <= 0.0f || a <= 0.0f) {
    return -1.0f;
  }
  float ratio = rs / r0;
  float ppm = a * powf(ratio, b);
  if (ppm < 0.0f) {
    return 0.0f;
  }
  return ppm;
}

}  // namespace simohe
