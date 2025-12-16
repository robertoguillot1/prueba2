# This file controls Flutter-level build steps. It should not be edited.
cmake_minimum_required(VERSION 3.14)
project(Flutter LANGUAGES CXX)

set(FLUTTER_MANAGED_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
set(FLUTTER_EPHEMERAL_DIR "${CMAKE_CURRENT_SOURCE_DIR}/ephemeral")

# === Application Helper Functions ===
# These functions are used by the runner CMakeLists.txt and plugins to build the application.

# Function for plugins (lowercase, as expected by plugins)
function(apply_standard_settings TARGET)
  target_compile_options(${TARGET} PRIVATE /W4 /WX /wd"4100")
  target_compile_options(${TARGET} PRIVATE /EHsc)
  target_compile_definitions(${TARGET} PRIVATE "_HAS_EXCEPTIONS=0")
  target_compile_definitions(${TARGET} PRIVATE "$<$<CONFIG:Debug>:_DEBUG>")
endfunction()

# Function for runner (uppercase, as used in runner/CMakeLists.txt)
function(APPLY_STANDARD_WINDOWS_SETTINGS TARGET)
  apply_standard_settings(${TARGET})
endfunction()

# The Flutter library and wrapper are handled by the ephemeral directory
# which is generated automatically by Flutter during the build process.
# The ephemeral/CMakeLists.txt is included automatically by Flutter's build system

