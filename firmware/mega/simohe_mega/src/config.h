#pragma once

#include <Arduino.h>
#include <stddef.h>
#include <stdint.h>

#define SIMOHE_FW_VERSION "0.1.0"
#define SIMOHE_PROTOCOL_VERSION 1

// --- Pin (Arduino Mega 2560) ---
constexpr uint8_t PIN_ONEWIRE = 2;
constexpr uint8_t PIN_MQ137 = A0;
constexpr uint8_t PIN_RELAY_VALVE = 7;   // K1
constexpr uint8_t PIN_RELAY_HEATER = 6;  // K2
constexpr uint8_t PIN_BUZZER = 8;

// 1 = modul relay aktif LOW, 0 = aktif HIGH. Sesuaikan modul.
constexpr uint8_t RELAY_ACTIVE_LOW = 0;

// --- Serial Mega <-> ESP8266 ---
// Umumnya Serial2 (TX2=16, RX2=17). Verifikasi DIP switch board masing-masing.
#define SIMOHE_ESP_SERIAL Serial2
constexpr uint32_t SERIAL_BAUD = 115200;

// --- Sensor DS18B20 ---
constexpr uint8_t TEMP_FILTER_SIZE = 5;
constexpr uint32_t TEMP_CONVERSION_MS = 800;

// --- Sensor MQ-137 ---
constexpr float MQ_VCC = 5.0f;
constexpr float MQ_RL_KOHM = 10.0f;
constexpr float MQ_RATIO_CLEAN = 3.6f;  // Rs/R0 di udara bersih (NH3)
constexpr float MQ_CURVE_A = 100.0f;    // ppm = a * (Rs/R0)^b (placeholder, kalibrasi)
constexpr float MQ_CURVE_B = -2.0f;

// --- Waktu loop ---
constexpr uint32_t SENSOR_INTERVAL_MS = 2000;
constexpr uint32_t TELEMETRY_INTERVAL_MS = 2000;
