# Project-level configuration.
cmake_minimum_required(VERSION 3.14)
project(ganaderia LANGUAGES CXX)

# The name of the executable created for the application. Change this to change
# the on-disk name of your application.
set(BINARY_NAME "ganaderia")

# Explicitly opt in to modern CMake behaviors to avoid warnings with recent
# versions of CMake.
cmake_policy(SET CMP0063 NEW)

# Define build configuration option.
get_property(IS_MULTICONFIG GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
if(IS_MULTICONFIG)
  set(CMAKE_CONFIGURATION_TYPES "Debug;Profile;Release"
    CACHE STRING "" FORCE)
else()
  if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "Release")
  endif()
  set(CMAKE_BUILD_TYPE "${CMAKE_BUILD_TYPE}" CACHE
    STRING "Choose the type of build." FORCE)
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS
    "Debug" "Profile" "Release")
endif()

# Use Unicode for all projects.
add_definitions(-DUNICODE -D_UNICODE)

# Define settings for the Profile build mode.
set(CMAKE_EXE_LINKER_FLAGS_PROFILE "${CMAKE_EXE_LINKER_FLAGS_RELEASE}")
set(CMAKE_SHARED_LINKER_FLAGS_PROFILE "${CMAKE_SHARED_LINKER_FLAGS_RELEASE}")
set(CMAKE_C_FLAGS_PROFILE "${CMAKE_C_FLAGS_RELEASE}")
set(CMAKE_CXX_FLAGS_PROFILE "${CMAKE_CXX_FLAGS_RELEASE}")

# Output directory.
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/intermediates_do_not_run")

# Generated plugin build files, which manage adding the dependencies for each
# plugin during the build.
set(FLUTTER_MANAGED_DIR "${CMAKE_SOURCE_DIR}/flutter")

# List of absolute paths to all plugins, including those managed by the
# Flutter tool and those added manually.
set(FLUTTER_PLUGIN_LIST
  "cloud_firestore"
  "connectivity_plus"
  "file_selector_windows"
  "firebase_auth"
  "firebase_core"
  "permission_handler_windows"
  "share_plus"
  "url_launcher_windows"
)

# List of absolute paths to all FFI plugins.
set(FLUTTER_FFI_PLUGIN_LIST
)

# System-level include directories.
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# === Installation ===
# By default, "installing" just makes a relocatable bundle in the build
# directory.
set(BUILD_BUNDLE_DIR "${CMAKE_BINARY_DIR}/bundle")
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  set(CMAKE_INSTALL_PREFIX "${BUILD_BUNDLE_DIR}" CACHE PATH "..." FORCE)
endif()

set(INSTALL_BUNDLE_DATA_DIR "${CMAKE_INSTALL_PREFIX}/data")
set(INSTALL_BUNDLE_LIB_DIR "${CMAKE_INSTALL_PREFIX}")

# === Helper Functions for Plugins ===
# These functions must be defined before including plugins
function(apply_standard_settings TARGET)
  target_compile_options(${TARGET} PRIVATE /W4 /WX /wd"4100")
  target_compile_options(${TARGET} PRIVATE /EHsc)
  target_compile_definitions(${TARGET} PRIVATE "_HAS_EXCEPTIONS=0")
  target_compile_definitions(${TARGET} PRIVATE "$<$<CONFIG:Debug>:_DEBUG>")
endfunction()

# Prepare the embedder build files.
# Note: generated_config.cmake is included in runner/CMakeLists.txt where it has a parent scope
# Do NOT include it here as it uses PARENT_SCOPE

# === Flutter Tooling ===
# Any new build files must be added to this list.
list(APPEND FLUTTER_BUILD_FILES
  "flutter/generated_plugin_registrant.cc"
  "flutter/generated_plugin_registrant.h"
)

# === Flutter App ===
# The application target. This is the default target in the build.
add_subdirectory("runner")

