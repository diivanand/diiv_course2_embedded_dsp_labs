add_executable(lab_0_2 src/main.cpp)
target_link_libraries(lab_0_2 PRIVATE course4_options engine_core)
add_executable(lab_0_2_bench bench/bench_main.cpp)
target_link_libraries(lab_0_2_bench PRIVATE course4_options engine_core benchmark::benchmark_main)
