#pragma once

#include <Arduino.h>
#include <stddef.h>
#include <stdint.h>

#define SIMOHE_FW_VERSION "0.1.0"
#define SIMOHE_PROTOCOL_VERSION 1

#define SIMOHE_INGEST_PATH "/functions/v1/iot-ingest"

constexpr uint32_t ESP_SERIAL_BAUD = 115200;

constexpr uint8_t PIN_STATUS_LED = LED_BUILTIN;
constexpr uint8_t STATUS_LED_ACTIVE_LOW = 1;

constexpr uint32_t PING_INTERVAL_MS = 30000;
constexpr uint32_t HTTP_TIMEOUT_MS = 10000;

// Buffer offline (RAM). Frame harus menampung badan ingest penuh (maks 900 byte).
// 8 frame x 1024 byte = 8 KB.
constexpr size_t OFFLINE_FRAME_SIZE = 1024;
constexpr size_t OFFLINE_CAPACITY = 8;
