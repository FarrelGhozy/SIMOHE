#include <simohe_core.h>
#include <unity.h>

#include <string.h>

using namespace simohe;

void setUp() {}
void tearDown() {}

static void test_moving_average(void) {
  float buffer[3];
  MovingAverage avg(buffer, 3);
  TEST_ASSERT_EQUAL_FLOAT(10.0f, avg.push(10.0f));
  TEST_ASSERT_EQUAL_FLOAT(15.0f, avg.push(20.0f));
  TEST_ASSERT_EQUAL_FLOAT(20.0f, avg.push(30.0f));
  TEST_ASSERT_EQUAL_FLOAT(30.0f, avg.push(40.0f));
}

static void test_gas_math(void) {
  TEST_ASSERT_EQUAL_FLOAT(10.0f, rsFromVoltage(2.5f, 5.0f, 10.0f));
  TEST_ASSERT_EQUAL_FLOAT(10.0f, r0FromCleanAir(36.0f, 3.6f));
  TEST_ASSERT_EQUAL_FLOAT(100.0f, ppmFromRs(10.0f, 10.0f, 100.0f, -2.0f));
  TEST_ASSERT_TRUE(rsFromVoltage(0.0f, 5.0f, 10.0f) < 0.0f);
}

static void test_thermal_auto_hysteresis(void) {
  HeaterConfig config;
  ThermalState state;
  thermalStep(state, config, true, 29.0f, 1000);
  TEST_ASSERT_TRUE(state.heater);
  thermalStep(state, config, true, 31.0f, 2000);
  TEST_ASSERT_TRUE(state.heater);
  thermalStep(state, config, true, 32.0f, 3000);
  TEST_ASSERT_FALSE(state.heater);
}

static void test_thermal_failsafe_sensor(void) {
  HeaterConfig config;
  ThermalState state;
  thermalStep(state, config, true, 29.0f, 1000);
  TEST_ASSERT_TRUE(state.heater);
  thermalStep(state, config, false, 29.0f, 2000);
  TEST_ASSERT_FALSE(state.heater);
}

static void test_thermal_force_on_expiry(void) {
  HeaterConfig config;
  ThermalState state;
  state.mode = HeaterMode::ForceOn;
  state.forceOnUntilMs = 5000;
  thermalStep(state, config, true, 40.0f, 1000);
  TEST_ASSERT_TRUE(state.heater);
  thermalStep(state, config, true, 29.0f, 6000);
  TEST_ASSERT_EQUAL(HeaterMode::Auto, state.mode);
  TEST_ASSERT_TRUE(state.heater);
}

static void test_thermal_safety_temp_high(void) {
  HeaterConfig config;
  ThermalState state;
  state.mode = HeaterMode::ForceOn;
  state.forceOnUntilMs = 100000;
  thermalStep(state, config, true, 46.0f, 1000);
  TEST_ASSERT_FALSE(state.heater);
  TEST_ASSERT_TRUE(state.safetyCutoff);
  TEST_ASSERT_EQUAL_STRING("temp_high", state.safetyReason);
  TEST_ASSERT_EQUAL(HeaterMode::Auto, state.mode);
}

static void test_thermal_safety_max_on(void) {
  HeaterConfig config;
  config.heaterMaxOnMin = 1;
  ThermalState state;
  thermalStep(state, config, true, 20.0f, 1000);
  TEST_ASSERT_TRUE(state.heater);
  thermalStep(state, config, true, 20.0f, 61000);
  TEST_ASSERT_FALSE(state.heater);
  TEST_ASSERT_TRUE(state.safetyCutoff);
  TEST_ASSERT_EQUAL_STRING("heater_max_on", state.safetyReason);
}

static void test_valve_auto_close(void) {
  HeaterConfig config;
  config.valveMaxOpenMin = 1;
  ValveState state;
  valveApplyOpen(state, 1000);
  TEST_ASSERT_TRUE(state.open);
  valveStep(state, config, 61000);
  TEST_ASSERT_FALSE(state.open);
  TEST_ASSERT_TRUE(state.safetyClosed);
}

static void test_maturity(void) {
  HeaterConfig config;
  config.nh3MaturePpm = 25.0f;
  config.matureHoldMin = 1;
  MaturityState state;
  maturityStep(state, config, true, 26.0f, 1000);
  maturityStep(state, config, true, 26.0f, 61000);
  TEST_ASSERT_TRUE(state.mature);
  TEST_ASSERT_TRUE(state.justMatured);
  maturityStep(state, config, true, 10.0f, 62000);
  TEST_ASSERT_FALSE(state.mature);
  TEST_ASSERT_EQUAL_UINT32(0, state.streakSec);
}

static void test_encode_telemetry(void) {
  Telemetry telemetry;
  telemetry.seq = 7;
  telemetry.tempC = 31.5f;
  telemetry.nh3Ppm = 18.0f;
  telemetry.tempOk = true;
  telemetry.nh3Ok = true;
  telemetry.heater = true;
  telemetry.mode = HeaterMode::ForceOn;
  char line[kMaxLine];
  size_t length = encodeTelemetry(telemetry, line, sizeof(line));
  TEST_ASSERT_TRUE(length > 0);
  TEST_ASSERT_NOT_NULL(strstr(line, "\"type\":\"telemetry\""));
  TEST_ASSERT_NOT_NULL(strstr(line, "\"mode\":\"FORCE_ON\""));
}

static void test_decode_command(void) {
  IncomingFrame frame;
  const char* line =
      "{\"type\":\"cmd\",\"id\":\"abc\",\"action\":\"heater_on\",\"args\":{\"duration_min\":45},"
      "\"expires_at\":\"2026-10-08T10:01:00Z\"}";
  TEST_ASSERT_TRUE(decodeLine(line, frame));
  TEST_ASSERT_EQUAL(FrameKind::Command, frame.kind);
  TEST_ASSERT_EQUAL_STRING("abc", frame.command.id);
  TEST_ASSERT_EQUAL_STRING("heater_on", frame.command.action);
  TEST_ASSERT_EQUAL_UINT32(45, frame.command.durationMin);
  TEST_ASSERT_TRUE(frame.command.hasExpiry);
}

static void test_decode_config(void) {
  IncomingFrame frame;
  const char* line =
      "{\"type\":\"config\",\"ingest_interval_sec\":10,\"temp_min_c\":30,\"temp_max_c\":45,"
      "\"temp_hysteresis_c\":2,\"nh3_mature_ppm\":25,\"mature_hold_min\":30,\"heater_auto\":1,"
      "\"heater_max_on_min\":60,\"valve_max_open_min\":10,\"command_ttl_sec\":60}";
  TEST_ASSERT_TRUE(decodeLine(line, frame));
  TEST_ASSERT_EQUAL(FrameKind::Config, frame.kind);
  TEST_ASSERT_TRUE(frame.configValid);
  TEST_ASSERT_TRUE(frame.config.heaterAuto);
  TEST_ASSERT_EQUAL_FLOAT(30.0f, frame.config.tempMinC);
  TEST_ASSERT_EQUAL_UINT32(10, frame.config.valveMaxOpenMin);
}

static void test_decode_bad_line(void) {
  IncomingFrame frame;
  TEST_ASSERT_FALSE(decodeLine("not-json", frame));
}

static void test_parse_iso_utc(void) {
  TEST_ASSERT_EQUAL_UINT32(1791453600UL, parseIso8601Utc("2026-10-08T10:00:00Z"));
  TEST_ASSERT_EQUAL_UINT32(0, parseIso8601Utc("invalid"));
}

int main(int, char**) {
  UNITY_BEGIN();
  RUN_TEST(test_moving_average);
  RUN_TEST(test_gas_math);
  RUN_TEST(test_thermal_auto_hysteresis);
  RUN_TEST(test_thermal_failsafe_sensor);
  RUN_TEST(test_thermal_force_on_expiry);
  RUN_TEST(test_thermal_safety_temp_high);
  RUN_TEST(test_thermal_safety_max_on);
  RUN_TEST(test_valve_auto_close);
  RUN_TEST(test_maturity);
  RUN_TEST(test_encode_telemetry);
  RUN_TEST(test_decode_command);
  RUN_TEST(test_decode_config);
  RUN_TEST(test_decode_bad_line);
  RUN_TEST(test_parse_iso_utc);
  return UNITY_END();
}
