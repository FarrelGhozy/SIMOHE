#include "actuators.h"

#include <Arduino.h>

void Actuators::begin() {
  pinMode(PIN_RELAY_VALVE, OUTPUT);
  pinMode(PIN_RELAY_HEATER, OUTPUT);
  pinMode(PIN_BUZZER, OUTPUT);
  writeRelay(PIN_RELAY_VALVE, false);
  writeRelay(PIN_RELAY_HEATER, false);
  digitalWrite(PIN_BUZZER, LOW);
  heaterOn_ = false;
  valveOn_ = false;
}

void Actuators::apply(bool heaterOn, bool valveOn) {
  if (heaterOn != heaterOn_) {
    writeRelay(PIN_RELAY_HEATER, heaterOn);
    heaterOn_ = heaterOn;
  }
  if (valveOn != valveOn_) {
    writeRelay(PIN_RELAY_VALVE, valveOn);
    valveOn_ = valveOn;
  }
}

void Actuators::writeRelay(uint8_t pin, bool on) {
  const uint8_t activeLevel = RELAY_ACTIVE_LOW ? LOW : HIGH;
  const uint8_t inactiveLevel = RELAY_ACTIVE_LOW ? HIGH : LOW;
  digitalWrite(pin, on ? activeLevel : inactiveLevel);
}
