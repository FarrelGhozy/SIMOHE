#pragma once

#include <stddef.h>

namespace simohe_esp {

// Ring buffer frame teks berukuran tetap. Saat penuh, frame terlama dibuang.
class OfflineBuffer {
 public:
  OfflineBuffer(char* storage, size_t frameSize, size_t capacity);

  bool push(const char* frame);
  const char* peek() const;
  void pop();
  void clear();

  bool empty() const { return count_ == 0; }
  bool full() const { return count_ == capacity_; }
  size_t size() const { return count_; }
  size_t capacity() const { return capacity_; }

 private:
  char* storage_;
  size_t frameSize_;
  size_t capacity_;
  size_t head_;
  size_t count_;
};

}  // namespace simohe_esp
