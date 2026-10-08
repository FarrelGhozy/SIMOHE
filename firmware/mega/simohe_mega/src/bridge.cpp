#include "bridge.h"

void MegaBridge::begin(Stream& serial) {
  serial_ = &serial;
  length_ = 0;
}

bool MegaBridge::readLine(char* out, size_t maxLen) {
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
      length_ = 0;  // baris terlalu panjang, buang
    }
  }
  return false;
}

bool MegaBridge::receiveWait(simohe::IncomingFrame& frame) {
  char line[simohe::kMaxLine];
  if (!readLine(line, sizeof(line))) {
    return false;
  }
  return simohe::decodeLine(line, frame);
}

void MegaBridge::sendTelemetry(const simohe::Telemetry& telemetry) {
  if (serial_ == nullptr) {
    return;
  }
  char line[simohe::kMaxLine];
  const size_t length = simohe::encodeTelemetry(telemetry, line, sizeof(line));
  if (length > 0) {
    serial_->write((const uint8_t*)line, length);
  }
}

void MegaBridge::sendEvent(const char* code, const char* detail) {
  if (serial_ == nullptr) {
    return;
  }
  char line[192];
  const size_t length = simohe::encodeEvent(code, detail, line, sizeof(line));
  if (length > 0) {
    serial_->write((const uint8_t*)line, length);
  }
}

void MegaBridge::sendAck(const char* id, bool ok) {
  if (serial_ == nullptr) {
    return;
  }
  char line[160];
  const size_t length = simohe::encodeAck(id, ok, line, sizeof(line));
  if (length > 0) {
    serial_->write((const uint8_t*)line, length);
  }
}
