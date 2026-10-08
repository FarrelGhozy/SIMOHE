#include "protocol.h"

namespace simohe {

const char* modeToString(HeaterMode mode) {
  switch (mode) {
    case HeaterMode::ForceOn:
      return "FORCE_ON";
    case HeaterMode::ForceOff:
      return "FORCE_OFF";
    case HeaterMode::Auto:
    default:
      return "AUTO";
  }
}

bool modeFromString(const char* text, HeaterMode& out) {
  if (text == nullptr) {
    return false;
  }
  if (text[0] == 'A' || text[0] == 'a') {
    out = HeaterMode::Auto;
    return true;
  }
  if (text[0] == 'F' || text[0] == 'f') {
    if (text[7] == 'N' || text[7] == 'n') {
      out = HeaterMode::ForceOn;
      return true;
    }
    if (text[7] == 'F' || text[7] == 'f') {
      out = HeaterMode::ForceOff;
      return true;
    }
  }
  return false;
}

}  // namespace simohe
