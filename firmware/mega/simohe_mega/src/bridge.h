#pragma once

#include <Arduino.h>

#include <simohe_core.h>

#include "config.h"

class MegaBridge {
 public:
  void begin(Stream& serial);

  bool readLine(char* out, size_t maxLen);
  bool receiveWait(simohe::IncomingFrame& frame);

  void sendTelemetry(const simohe::Telemetry& telemetry);
  void sendEvent(const char* code, const char* detail);
  void sendAck(const char* id, bool ok);

 private:
  Stream* serial_ = nullptr;
  char buffer_[simohe::kMaxLine];
  size_t length_ = 0;
};
