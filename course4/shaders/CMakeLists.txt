# GLSL -> SPIR-V via glslc (ships with the LunarG SDK). If glslc isn't on the
# PATH the target degrades to a status message instead of failing the build.
find_program(GLSLC glslc)
file(GLOB_RECURSE glsl_sources CONFIGURE_DEPENDS
  ${CMAKE_CURRENT_SOURCE_DIR}/glsl/*.vert
  ${CMAKE_CURRENT_SOURCE_DIR}/glsl/*.frag
  ${CMAKE_CURRENT_SOURCE_DIR}/glsl/*.comp)

if(NOT GLSLC)
  message(STATUS "course4: glslc not found — shader compilation target disabled (install the Vulkan SDK)")
  return()
endif()

set(spv_outputs "")
foreach(src ${glsl_sources})
  get_filename_component(name ${src} NAME)
  set(out ${CMAKE_BINARY_DIR}/shaders/${name}.spv)
  add_custom_command(OUTPUT ${out}
    COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/shaders
    COMMAND ${GLSLC} -O ${src} -o ${out}
    DEPENDS ${src} COMMENT "glslc ${name}")
  list(APPEND spv_outputs ${out})
endforeach()

add_custom_target(compile_shaders ALL DEPENDS ${spv_outputs})
