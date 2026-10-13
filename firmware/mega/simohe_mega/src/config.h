#pragma once

#include <Arduino.h>
#include <stddef.h>
#include <stdint.h>

#define SIMOHE_FW_VERSION "0.1.0"
#define SIMOHE_PROTOCOL_VERSION 1

// Debug ke Serial0 (USB). 1 = aktif (bench/HIL), 0 = mati.
#ifndef SIMOHE_DEBUG
#define SIMOHE_DEBUG 1
#endif

// --- Pin (Arduino Mega 2560) ---
constexpr uint8_t PIN_ONEWIRE = 2;
constexpr uint8_t PIN_MQ137 = A0;
constexpr uint8_t PIN_RELAY_VALVE = 7;   // K1
constexpr uint8_t PIN_RELAY_HEATER = 6;  // K2
constexpr uint8_t PIN_BUZZER = 8;

// 1 = modul relay aktif LOW (umum: optoisolated "Low level trigger"),
// 0 = aktif HIGH. WAJIB sesuaikan modul; salah = aktuator terbalik (bahaya).
constexpr uint8_t RELAY_ACTIVE_LOW = 1;

// --- Serial Mega <-> ESP8266 ---
// Board RobotDyn MEGA+WiFi R3: Mega<->ESP pada Serial3 (TX3=14, RX3=15).
#define SIMOHE_ESP_SERIAL Serial3
constexpr uint32_t SERIAL_BAUD = 115200;

// --- Sensor DS18B20 ---
constexpr uint8_t TEMP_FILTER_SIZE = 5;
constexpr uint8_t PPM_FILTER_SIZE = 8;  // filter ppm NH3 agar maturity/telemetri stabil
constexpr uint32_t TEMP_CONVERSION_MS = 800;  // cukup untuk resolusi 12-bit (750 ms)
constexpr uint32_t SENSOR_RESCAN_MS = 5000;   // pindai ulang bus bila sensor tak terdeteksi

// --- Sensor MQ-137 ---
// Catatan: RL saling hapus pada ppm = a * (Rs/R0)^b karena R0 = Rs_clean / ratio_clean.
// Nilai RL hanya memengaruhi Rs absolut & resolusi ADC.
constexpr float MQ_VCC = 5.0f;
constexpr float MQ_RL_KOHM = 10.0f;
constexpr float MQ_RATIO_CLEAN = 3.6f;  // Rs/R0 di udara bersih (NH3, datasheet)
// Kurva dari datasheet MQ-137 (NH3): 40 ppm @ Rs/R0=1.0 dan 100 ppm @ Rs/R0=0.8.
constexpr float MQ_CURVE_A = 40.0f;    // ppm = a * (Rs/R0)^b
constexpr float MQ_CURVE_B = -4.106f;
// Kalibrasi R0 otomatis (sekali) dari udara bersih. WARMUP 30s hanya untuk
// transient boot; preheat sensor 24-48 jam TETAP wajib sebelum nilai dipercaya.
// Lihat docs/04. Kalibrasi ulang via perintah Serial "cal" di udara bersih.
constexpr uint32_t MQ_CAL_WARMUP_MS = 30000;  // jeda awal sebelum menakar R0
constexpr uint16_t MQ_CAL_SAMPLES = 15;       // jumlah sampel yang dirata-rata
constexpr float MQ_CAL_MAX_SPREAD = 0.2f;     // (max-min) <= spread * rata-rata (ketat)

// --- Waktu loop ---
constexpr uint32_t SENSOR_INTERVAL_MS = 2000;
constexpr uint32_t TELEMETRY_INTERVAL_MS = 2000;
