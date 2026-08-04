add_library(engine_vulkan
  vk_stub.cpp)
target_include_directories(engine_vulkan PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/..)
target_link_libraries(engine_vulkan
  PUBLIC engine_core volk glfw GPUOpen::VulkanMemoryAllocator)
