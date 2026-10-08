#include "offline_buffer.h"

#include <string.h>

namespace simohe_esp {

OfflineBuffer::OfflineBuffer(char* storage, size_t frameSize, size_t capacity)
    : storage_(storage), frameSize_(frameSize), capacity_(capacity), head_(0), count_(0) {}

bool OfflineBuffer::push(const char* frame) {
  if (storage_ == nullptr || frameSize_ == 0 || capacity_ == 0 || frame == nullptr) {
    return false;
  }
  if (count_ == capacity_) {
    head_ = (head_ + 1) % capacity_;
    count_--;
  }
  const size_t slot = (head_ + count_) % capacity_;
  strncpy(storage_ + slot * frameSize_, frame, frameSize_ - 1);
  storage_[slot * frameSize_ + frameSize_ - 1] = '\0';
  count_++;
  return true;
}

const char* OfflineBuffer::peek() const {
  if (count_ == 0) {
    return nullptr;
  }
  return storage_ + head_ * frameSize_;
}

void OfflineBuffer::pop() {
  if (count_ == 0) {
    return;
  }
  head_ = (head_ + 1) % capacity_;
  count_--;
}

void OfflineBuffer::clear() {
  head_ = 0;
  count_ = 0;
}

}  // namespace simohe_esp
