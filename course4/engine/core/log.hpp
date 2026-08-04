#pragma once
#include <string_view>

// Minimal logging scaffold — grows with the engine (Lab 0.1 wires it up;
// Lab 0.3 routes the Vulkan debug messenger through it).
namespace c4 {

enum class log_level { trace, info, warn, error };

void log(log_level level, std::string_view msg);
inline void log(std::string_view msg) { log(log_level::info, msg); }

}  // namespace c4
