#pragma once

#include <Arduino.h>

#include <simohe_core.h>
#include <simohe_esp_core.h>

class EspBridge {
 public:
  void begin(Stream& serial);

  bool readLine(char* out, size_t maxLen);
  bool receive(simohe::IncomingFrame& frame);

  void sendCommand(const simohe_esp::ServerCommand& command);
  void sendConfig(const simohe::HeaterConfig& config);
  void sendPing();

 private:
  Stream* serial_ = nullptr;
  char buffer_[simohe::kMaxLine];
  size_t length_ = 0;
};
