# course4_options — the interface target every course target links.
# Usage requirements only; no global flags anywhere in this tree.

add_library(course4_options INTERFACE)

target_compile_features(course4_options INTERFACE cxx_std_20)

if(CMAKE_CXX_COMPILER_ID MATCHES "Clang|GNU|AppleClang")
  target_compile_options(course4_options INTERFACE
    -Wall -Wextra -Wpedantic -Wshadow -Wconversion)
endif()

if(COURSE4_SANITIZE)
  target_compile_options(course4_options INTERFACE
    -fsanitize=address,undefined -fno-omit-frame-pointer)
  target_link_options(course4_options INTERFACE
    -fsanitize=address,undefined)
endif()
