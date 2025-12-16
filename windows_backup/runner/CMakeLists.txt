cmake_minimum_required(VERSION 3.14)
project(Runner LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Application-level configuration.
set(APPLICATION_NAME "ganaderia")
set(APPLICATION_ENTRY_POINT "flutter/main.dart")
set(APPLICATION_ICON "${CMAKE_CURRENT_SOURCE_DIR}/resources/app_icon.ico")
set(APPLICATION_VERSION "1.0.0+1")
set(APPLICATION_LEGAL_COPYRIGHT "Copyright © 2024 ganaderia. All rights reserved.")
set(APPLICATION_AUTHOR_EMAIL "user@example.com")
set(APPLICATION_REPOSITORY "https://github.com/user/ganaderia")
set(APPLICATION_ISSUE_TRACKER "https://github.com/user/ganaderia/issues")

# Use Unicode for all projects.
add_definitions(-DUNICODE -D_UNICODE)

# === Flutter Library ===
# Build settings for the Flutter library.
set(FLUTTER_MANAGED_DIR "${CMAKE_SOURCE_DIR}/flutter")
set(FLUTTER_EPHEMERAL_DIR "${CMAKE_SOURCE_DIR}/flutter/ephemeral")

# Build settings for the Flutter library.
add_subdirectory(${FLUTTER_MANAGED_DIR} flutter)

# Include generated config (must be done in a subdirectory for PARENT_SCOPE to work)
include("${FLUTTER_EPHEMERAL_DIR}/generated_config.cmake")

# === Application Target ===
# The executable for the application.
add_executable(${BINARY_NAME} WIN32
  "main.cpp"
  "flutter_window.cpp"
  "win32_window.cpp"
  "utils.cpp"
  "Runner.rc"
  "${FLUTTER_MANAGED_DIR}/generated_plugin_registrant.cc"
)

# Apply standard Windows-specific settings.
apply_standard_windows_settings(${BINARY_NAME})

# Link the Flutter library.
target_link_libraries(${BINARY_NAME} PRIVATE flutter flutter_wrapper_app)

# Include and link plugins (must be done after target is created)
set(FLUTTER_PLUGIN_LIST
  cloud_firestore
  connectivity_plus
  file_selector_windows
  firebase_auth
  firebase_core
  permission_handler_windows
  share_plus
  url_launcher_windows
)

set(PLUGIN_BUNDLED_LIBRARIES)

foreach(plugin ${FLUTTER_PLUGIN_LIST})
  add_subdirectory(${CMAKE_SOURCE_DIR}/flutter/ephemeral/.plugin_symlinks/${plugin}/windows plugins/${plugin})
  target_link_libraries(${BINARY_NAME} PRIVATE ${plugin}_plugin)
  list(APPEND PLUGIN_BUNDLED_LIBRARIES $<TARGET_FILE:${plugin}_plugin>)
endforeach(plugin)

# Add preprocessor definitions for the application.
target_compile_definitions(${BINARY_NAME} PRIVATE
  "APPLICATION_NAME=\"${APPLICATION_NAME}\""
  "APPLICATION_ENTRY_POINT=\"${APPLICATION_ENTRY_POINT}\""
  "APPLICATION_ICON=\"${APPLICATION_ICON}\""
  "APPLICATION_VERSION=\"${APPLICATION_VERSION}\""
  "APPLICATION_LEGAL_COPYRIGHT=\"${APPLICATION_LEGAL_COPYRIGHT}\""
  "APPLICATION_AUTHOR_EMAIL=\"${APPLICATION_AUTHOR_EMAIL}\""
  "APPLICATION_REPOSITORY=\"${APPLICATION_REPOSITORY}\""
  "APPLICATION_ISSUE_TRACKER=\"${APPLICATION_ISSUE_TRACKER}\""
)

# Run the Flutter tooling to generate any needed files.
add_custom_command(TARGET ${BINARY_NAME} POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E env
    "${FLUTTER_EPHEMERAL_DIR}/flutter_wrapper.bat" assemble
    -dDebug
    --output="${CMAKE_BINARY_DIR}/intermediates_do_not_run/flutter"
    --depfile="${CMAKE_BINARY_DIR}/intermediates_do_not_run/flutter_${CMAKE_BUILD_TYPE}.d"
    -dTargetPlatform=windows-x64
    -dTargetFile="${APPLICATION_ENTRY_POINT}"
    -dBuildMode=${CMAKE_BUILD_TYPE}
    -dTreeShakeIcons=${TREE_SHAKE_ICONS}
    -dDartDefines=${DART_DEFINES}
    -dSplitDebugInfo=${SPLIT_DEBUG_INFO}
    -dTrackWidgetCreation=${TRACK_WIDGET_CREATION}
    -dFontSubset=${FONT_SUBSET}
    VERBATIM
)

