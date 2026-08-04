#include "core/log.hpp"

#include <cstdio>

namespace c4 {

void log(log_level level, std::string_view msg) {
    static constexpr const char* tags[] = {"trace", "info ", "warn ", "error"};
    std::printf("[%s] %.*s\n", tags[static_cast<int>(level)],
                static_cast<int>(msg.size()), msg.data());
}

}  // namespace c4
