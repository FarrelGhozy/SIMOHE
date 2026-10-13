#pragma once

#include <stddef.h>
#include <string.h>

namespace simohe {

// Salin string dengan garansi null-terminated. Aman untuk capacity==0.
// Mengembalikan true bila seluruh source muat (tidak terpotong).
inline bool safeCopy(char* dst, size_t capacity, const char* src) {
  if (dst == nullptr || capacity == 0) {
    return false;
  }
  if (src == nullptr) {
    dst[0] = '\0';
    return false;
  }
  const size_t len = strlen(src);
  const size_t copy = len < capacity - 1 ? len : capacity - 1;
  if (copy > 0) {
    memcpy(dst, src, copy);
  }
  dst[copy] = '\0';
  return len < capacity;
}

// Panjang string dengan batas atas (tidak baca lewat maxLen).
inline size_t safeLen(const char* text, size_t maxLen) {
  if (text == nullptr) {
    return 0;
  }
  size_t len = 0;
  while (len < maxLen && text[len] != '\0') {
    len++;
  }
  return len;
}

// True bila now sudah mencapai/melanggar deadline ms (aman overflow millis()).
inline bool timeReached(uint32_t nowMs, uint32_t deadlineMs) {
  return (int32_t)(nowMs - deadlineMs) >= 0;
}

}  // namespace simohe
