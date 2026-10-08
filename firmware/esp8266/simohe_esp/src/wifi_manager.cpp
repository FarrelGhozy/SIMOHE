#include "wifi_manager.h"

#include <ESP8266WiFi.h>
#include <simohe_esp_core.h>

#include "config.h"
#include "credentials.h"

void WifiManager::begin() {
  WiFi.persistent(false);
  WiFi.mode(WIFI_STA);
  WiFi.setAutoReconnect(false);
  WiFi.begin(SIMOHE_WIFI_SSID, SIMOHE_WIFI_PASSWORD);
  nextAttemptMs_ = millis() + simohe_esp::backoffDelayMs(0);
}

void WifiManager::loop(uint32_t nowMs) {
  if (WiFi.status() == WL_CONNECTED) {
    connected_ = true;
    attempt_ = 0;
    return;
  }

  connected_ = false;
  if (nowMs < nextAttemptMs_) {
    return;
  }

  WiFi.disconnect();
  WiFi.begin(SIMOHE_WIFI_SSID, SIMOHE_WIFI_PASSWORD);
  nextAttemptMs_ = nowMs + simohe_esp::backoffDelayMs(attempt_);
  if (attempt_ < 255) {
    attempt_++;
  }
}
