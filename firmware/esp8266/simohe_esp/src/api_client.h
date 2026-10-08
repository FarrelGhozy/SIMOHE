#pragma once

#include <Arduino.h>
#include <stddef.h>

class ApiClient {
 public:
  // Mengirim body JSON ke endpoint ingest. Mengembalikan true bila HTTP 200.
  // `statusCode` diisi kode HTTP (<=0 bila gagal koneksi).
  bool postIngest(const char* body, char* responseOut, size_t responseSize, int& statusCode);
};
