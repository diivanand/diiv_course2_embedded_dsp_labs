add_library(engine_core
  log.cpp)
target_include_directories(engine_core PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/..)
target_link_libraries(engine_core
  PUBLIC course4_options glm::glm Tracy::TracyClient)
