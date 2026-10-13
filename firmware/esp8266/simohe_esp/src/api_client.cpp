#include "api_client.h"

#include <ESP8266HTTPClient.h>
#include <ESP8266WiFi.h>
#include <WiFiClientSecureBearSSL.h>
#include <simohe_core.h>
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
    // CATATAN KEAMANAN: setInsecure() tanpa validasi sertifikat rentan MITM.
    // Untuk produksi HTTPS, ganti dengan fingerprint/CA. HTTP lokal tetap aman.
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
      // Truncate aman; parser akan menolak JSON terpotong.
      simohe::safeCopy(responseOut, responseSize, payload.c_str());
    }
    ok = statusCode == 200;
  } else if (responseOut != nullptr && responseSize > 0) {
    responseOut[0] = '\0';
  }
  http.end();
  return ok;
}
