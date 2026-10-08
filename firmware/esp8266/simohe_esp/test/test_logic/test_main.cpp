#include <simohe_core.h>
#include <simohe_esp_core.h>
#include <unity.h>

#include <string.h>

using namespace simohe;
using namespace simohe_esp;

void setUp() {}
void tearDown() {}

static void test_backoff_growth(void) {
  TEST_ASSERT_EQUAL_UINT32(2000, backoffDelayMs(0));
  TEST_ASSERT_EQUAL_UINT32(4000, backoffDelayMs(1));
  TEST_ASSERT_EQUAL_UINT32(8000, backoffDelayMs(2));
  TEST_ASSERT_EQUAL_UINT32(16000, backoffDelayMs(3));
  TEST_ASSERT_EQUAL_UINT32(32000, backoffDelayMs(4));
  TEST_ASSERT_EQUAL_UINT32(60000, backoffDelayMs(5));
  TEST_ASSERT_EQUAL_UINT32(60000, backoffDelayMs(20));
}

static void test_offline_buffer_overflow(void) {
  char storage[3 * 8];
  OfflineBuffer buffer(storage, 8, 3);
  TEST_ASSERT_TRUE(buffer.push("a"));
  TEST_ASSERT_TRUE(buffer.push("b"));
  TEST_ASSERT_TRUE(buffer.push("c"));
  TEST_ASSERT_TRUE(buffer.full());
  TEST_ASSERT_EQUAL_STRING("a", buffer.peek());
  TEST_ASSERT_TRUE(buffer.push("d"));
  TEST_ASSERT_EQUAL_STRING("b", buffer.peek());
  TEST_ASSERT_EQUAL_UINT(3, buffer.size());
  buffer.pop();
  TEST_ASSERT_EQUAL_STRING("c", buffer.peek());
}

static void test_offline_buffer_fifo(void) {
  char storage[4 * 8];
  OfflineBuffer buffer(storage, 8, 4);
  buffer.push("1");
  buffer.push("2");
  TEST_ASSERT_EQUAL_STRING("1", buffer.peek());
  buffer.pop();
  TEST_ASSERT_EQUAL_STRING("2", buffer.peek());
  buffer.pop();
  TEST_ASSERT_TRUE(buffer.empty());
}

static void test_parse_ingest_response(void) {
  const char* json =
      "{\"server_time\":\"2026-10-08T10:00:06Z\",\"config\":{\"ingest_interval_sec\":10,"
      "\"temp_min_c\":30,\"temp_max_c\":45,\"temp_hysteresis_c\":2,\"nh3_mature_ppm\":25,"
      "\"mature_hold_min\":30,\"heater_auto\":1,\"heater_max_on_min\":60,"
      "\"valve_max_open_min\":10,\"command_ttl_sec\":60},\"commands\":[{\"id\":\"c1\","
      "\"action\":\"valve_open\",\"args\":{},\"expires_at\":\"2026-10-08T10:01:05Z\"}],"
      "\"poll_after_sec\":5}";
  IngestResult result;
  TEST_ASSERT_TRUE(parseIngestResponse(json, result));
  TEST_ASSERT_TRUE(result.valid);
  TEST_ASSERT_EQUAL_UINT16(10, result.config.ingestIntervalSec);
  TEST_ASSERT_EQUAL_UINT16(5, result.pollAfterSec);
  TEST_ASSERT_EQUAL_STRING("2026-10-08T10:00:06Z", result.serverTime);
  TEST_ASSERT_EQUAL_UINT(1, result.commandCount);
  TEST_ASSERT_EQUAL_STRING("c1", result.commands[0].id);
  TEST_ASSERT_EQUAL_STRING("valve_open", result.commands[0].action);
  TEST_ASSERT_TRUE(result.commands[0].hasExpiry);
}

static void test_parse_ingest_response_invalid(void) {
  IngestResult result;
  TEST_ASSERT_FALSE(parseIngestResponse("not-json", result));
  TEST_ASSERT_FALSE(parseIngestResponse("{\"foo\":1}", result));
}

static void test_build_ingest_body(void) {
  Telemetry telemetry;
  telemetry.seq = 12;
  telemetry.tempC = 31.2f;
  telemetry.nh3Ppm = 18.4f;
  telemetry.tempOk = true;
  telemetry.nh3Ok = true;
  telemetry.heater = true;
  telemetry.mode = HeaterMode::Auto;
  telemetry.uptimeSec = 99;

  EventItem events[1] = {{"SAFETY_CUTOFF", "temp_high"}};
  AckItem acks[1] = {{"c1", true}};

  char body[900];
  const size_t length =
      buildIngestBody(telemetry, "0.1.0", "2026-10-08T10:00:00Z", events, 1, acks, 1, body,
                      sizeof(body));
  TEST_ASSERT_TRUE(length > 0);
  TEST_ASSERT_NOT_NULL(strstr(body, "\"temp_c\":31.2"));
  TEST_ASSERT_NOT_NULL(strstr(body, "\"code\":\"SAFETY_CUTOFF\""));
  TEST_ASSERT_NOT_NULL(strstr(body, "\"id\":\"c1\""));
  TEST_ASSERT_NOT_NULL(strstr(body, "\"mode\":\"AUTO\""));
}

static void test_build_ingest_body_null_sensors(void) {
  Telemetry telemetry;
  telemetry.tempOk = false;
  telemetry.nh3Ok = false;
  char body[900];
  const size_t length =
      buildIngestBody(telemetry, "0.1.0", "2026-10-08T10:00:00Z", nullptr, 0, nullptr, 0, body,
                      sizeof(body));
  TEST_ASSERT_TRUE(length > 0);
  TEST_ASSERT_NOT_NULL(strstr(body, "\"temp_c\":null"));
  TEST_ASSERT_NOT_NULL(strstr(body, "\"nh3_ppm\":null"));
}

static void test_format_iso_roundtrip(void) {
  char buffer[24];
  const size_t length = formatIso8601Utc(1791453600UL, buffer, sizeof(buffer));
  TEST_ASSERT_EQUAL_UINT(20, length);
  TEST_ASSERT_EQUAL_STRING("2026-10-08T10:00:00Z", buffer);
  TEST_ASSERT_EQUAL_UINT32(1791453600UL, parseIso8601Utc(buffer));
}

int main(int, char**) {
  UNITY_BEGIN();
  RUN_TEST(test_backoff_growth);
  RUN_TEST(test_offline_buffer_overflow);
  RUN_TEST(test_offline_buffer_fifo);
  RUN_TEST(test_parse_ingest_response);
  RUN_TEST(test_parse_ingest_response_invalid);
  RUN_TEST(test_build_ingest_body);
  RUN_TEST(test_build_ingest_body_null_sensors);
  RUN_TEST(test_format_iso_roundtrip);
  return UNITY_END();
}
