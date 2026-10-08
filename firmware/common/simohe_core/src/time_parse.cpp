#include "time_parse.h"

#include <stdio.h>

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

void civilFromDays(int days, int& year, unsigned& month, unsigned& day) {
  days += 719468;
  const int era = (days >= 0 ? days : days - 146096) / 146097;
  const unsigned doe = (unsigned)(days - era * 146097);
  const unsigned yoe = (doe - doe / 1460 + doe / 36524 - doe / 146096) / 365;
  const int y = (int)yoe + era * 400;
  const unsigned doy = doe - (365 * yoe + yoe / 4 - yoe / 100);
  const unsigned mp = (5 * doy + 2) / 153;
  day = doy - (153 * mp + 2) / 5 + 1;
  month = mp + (mp < 10 ? 3 : -9);
  year = y + (month <= 2);
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

size_t formatIso8601Utc(uint32_t epoch, char* out, size_t outSize) {
  if (out == nullptr || outSize < 21 || epoch == 0) {
    return 0;
  }
  const int days = (int)(epoch / 86400UL);
  const uint32_t remainder = epoch % 86400UL;
  const int hour = (int)(remainder / 3600UL);
  const int minute = (int)((remainder % 3600UL) / 60UL);
  const int second = (int)(remainder % 60UL);

  int year = 0;
  unsigned month = 0;
  unsigned day = 0;
  civilFromDays(days, year, month, day);

  const int written = snprintf(out, outSize, "%04d-%02u-%02uT%02d:%02d:%02dZ", year, month, day,
                               hour, minute, second);
  if (written <= 0) {
    return 0;
  }
  return (size_t)written;
}

}  // namespace simohe
