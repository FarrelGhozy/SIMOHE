#include "api_client.h"

#include <ESP8266HTTPClient.h>
#include <ESP8266WiFi.h>
#include <WiFiClientSecureBearSSL.h>
#include <string.h>

#include "config.h"
#include "credentials.h"

bool ApiClient::postIngest(const char* body, char* responseOut, size_t responseSize,
                           int& statusCode) {
  statusCode = 0;
  if (body == nullptr) {
    return false;
  }

  const String url = String(SIMOHE_BASE_URL) + SIMOHE_INGEST_PATH;
  HTTPClient http;
  http.setTimeout(HTTP_TIMEOUT_MS);

  bool begun = false;
  if (url.startsWith("https")) {
    static BearSSL::WiFiClientSecure secureClient;
    secureClient.setInsecure();
    begun = http.begin(secureClient, url);
  } else {
    static WiFiClient plainClient;
    begun = http.begin(plainClient, url);
  }
  if (!begun) {
    return false;
  }

  http.addHeader("Content-Type", "application/json");
  http.addHeader("X-Device-Key", SIMOHE_DEVICE_KEY);

  statusCode = http.POST((uint8_t*)body, strlen(body));
  bool ok = false;
  if (statusCode > 0) {
    const String payload = http.getString();
    if (responseOut != nullptr && responseSize > 0) {
      strncpy(responseOut, payload.c_str(), responseSize - 1);
      responseOut[responseSize - 1] = '\0';
    }
    ok = statusCode == 200;
  }
  http.end();
  return ok;
}
