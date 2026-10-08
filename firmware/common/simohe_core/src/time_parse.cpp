#include "time_parse.h"

namespace simohe {

namespace {

bool isDigit(char c) { return c >= '0' && c <= '9'; }

int readNumber(const char* text, int length) {
  int value = 0;
  for (int i = 0; i < length; i++) {
    if (!isDigit(text[i])) {
      return -1;
    }
    value = value * 10 + (text[i] - '0');
  }
  return value;
}

int daysFromCivil(int year, unsigned month, unsigned day) {
  year -= month <= 2;
  const int era = (year >= 0 ? year : year - 399) / 400;
  const unsigned yoe = (unsigned)(year - era * 400);
  const unsigned doy = (153 * (month + (month > 2 ? -3 : 9)) + 2) / 5 + day - 1;
  const unsigned doe = yoe * 365 + yoe / 4 - yoe / 100 + doy;
  return era * 146097 + (int)doe - 719468;
}

}  // namespace

uint32_t parseIso8601Utc(const char* text) {
  if (text == nullptr) {
    return 0;
  }
  if (text[4] != '-' || text[7] != '-' || text[10] != 'T' || text[13] != ':' || text[16] != ':') {
    return 0;
  }

  const int year = readNumber(text, 4);
  const int month = readNumber(text + 5, 2);
  const int day = readNumber(text + 8, 2);
  const int hour = readNumber(text + 11, 2);
  const int minute = readNumber(text + 14, 2);
  const int second = readNumber(text + 17, 2);

  if (year < 0 || month < 1 || month > 12 || day < 1 || day > 31 || hour < 0 || hour > 23 ||
      minute < 0 || minute > 59 || second < 0 || second > 60) {
    return 0;
  }

  const int days = daysFromCivil(year, (unsigned)month, (unsigned)day);
  const int64_t epoch =
      (int64_t)days * 86400 + hour * 3600 + minute * 60 + second;
  if (epoch <= 0) {
    return 0;
  }
  return (uint32_t)epoch;
}

}  // namespace simohe
