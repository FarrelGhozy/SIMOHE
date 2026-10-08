#pragma once

#include <stddef.h>

#include "protocol.h"

namespace simohe {

size_t encodeTelemetry(const Telemetry& telemetry, char* out, size_t outSize);
size_t encodeEvent(const char* code, const char* detail, char* out, size_t outSize);
size_t encodeAck(const char* id, bool ok, char* out, size_t outSize);
size_t encodeCommand(const Command& command, char* out, size_t outSize);
size_t encodeConfig(const HeaterConfig& config, char* out, size_t outSize);
size_t encodePing(char* out, size_t outSize);

bool decodeLine(const char* line, IncomingFrame& out);

}  // namespace simohe
