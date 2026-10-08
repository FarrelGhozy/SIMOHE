#pragma once

#include <Arduino.h>
#include <stddef.h>
#include <stdint.h>

#define SIMOHE_FW_VERSION "0.1.0"
#define SIMOHE_PROTOCOL_VERSION 1

#define SIMOHE_INGEST_PATH "/api/iot/ingest"

constexpr uint32_t ESP_SERIAL_BAUD = 115200;

constexpr uint8_t PIN_STATUS_LED = LED_BUILTIN;
constexpr uint8_t STATUS_LED_ACTIVE_LOW = 1;

constexpr uint32_t PING_INTERVAL_MS = 30000;
constexpr uint32_t HTTP_TIMEOUT_MS = 10000;

// Buffer offline (RAM). 30 frame x 224 byte ~= 6.5 KB.
constexpr size_t OFFLINE_FRAME_SIZE = 224;
constexpr size_t OFFLINE_CAPACITY = 30;
