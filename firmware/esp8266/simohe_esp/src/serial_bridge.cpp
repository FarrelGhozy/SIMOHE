#include "serial_bridge.h"

#include <string.h>

void EspBridge::begin(Stream& serial) {
  serial_ = &serial;
  length_ = 0;
}

bool EspBridge::readLine(char* out, size_t maxLen) {
  if (serial_ == nullptr || maxLen == 0) {
    return false;
  }

  while (serial_->available() > 0) {
    const char c = (char)serial_->read();
    if (c == '\r') {
      continue;
    }
    if (c == '\n') {
      if (length_ == 0) {
        continue;
      }
      const size_t copy = length_ < maxLen - 1 ? length_ : maxLen - 1;
      memcpy(out, buffer_, copy);
      out[copy] = '\0';
      length_ = 0;
      return true;
    }
    if (length_ < sizeof(buffer_) - 1) {
      buffer_[length_++] = c;
    } else {
      length_ = 0;
    }
  }
  return false;
}

bool EspBridge::receive(simohe::IncomingFrame& frame) {
  char line[simohe::kMaxLine];
  if (!readLine(line, sizeof(line))) {
    return false;
  }
  return simohe::decodeLine(line, frame);
}

void EspBridge::sendCommand(const simohe_esp::ServerCommand& command) {
  if (serial_ == nullptr) {
    return;
  }
  simohe::Command outgoing;
  strncpy(outgoing.id, command.id, sizeof(outgoing.id) - 1);
  strncpy(outgoing.action, command.action, sizeof(outgoing.action) - 1);
  outgoing.durationMin = command.durationMin;
  outgoing.hasExpiry = command.hasExpiry;
  outgoing.expiresAtEpoch = command.expiresAtEpoch;

  char line[256];
  const size_t length = simohe::encodeCommand(outgoing, line, sizeof(line));
  if (length > 0) {
    serial_->write((const uint8_t*)line, length);
  }
}

void EspBridge::sendConfig(const simohe::HeaterConfig& config) {
  if (serial_ == nullptr) {
    return;
  }
  char line[384];
  const size_t length = simohe::encodeConfig(config, line, sizeof(line));
  if (length > 0) {
    serial_->write((const uint8_t*)line, length);
  }
}

void EspBridge::sendPing() {
  if (serial_ == nullptr) {
    return;
  }
  char line[96];
  const size_t length = simohe::encodePing(line, sizeof(line));
  if (length > 0) {
    serial_->write((const uint8_t*)line, length);
  }
}
