include(FetchContent)

set(ANTLR4_ROOT ${CMAKE_CURRENT_BINARY_DIR}/_deps/antlr4_runtime-src)
set(ANTLR4_INCLUDE_DIRS ${ANTLR4_ROOT}/runtime/Cpp/runtime/src)
set(ANTLR4_GIT_REPOSITORY https://github.com/antlr/antlr4.git)

if(${CMAKE_GENERATOR} MATCHES "Visual Studio.*")
  set(ANTLR4_OUTPUT_DIR ${ANTLR4_ROOT}/runtime/Cpp/dist/$(Configuration))
elseif(${CMAKE_GENERATOR} MATCHES "Xcode.*")
  set(ANTLR4_OUTPUT_DIR ${ANTLR4_ROOT}/runtime/Cpp/dist/$(CONFIGURATION))
else()
  set(ANTLR4_OUTPUT_DIR ${ANTLR4_ROOT}/runtime/Cpp/dist)
endif()

if(MSVC)
  set(ANTLR4_STATIC_LIBRARIES
      ${ANTLR4_OUTPUT_DIR}/antlr4-runtime-static.lib)
  set(ANTLR4_SHARED_LIBRARIES
      ${ANTLR4_OUTPUT_DIR}/antlr4-runtime.lib)
  set(ANTLR4_RUNTIME_LIBRARIES
      ${ANTLR4_OUTPUT_DIR}/antlr4-runtime.dll)
else()
  set(ANTLR4_STATIC_LIBRARIES
      ${ANTLR4_OUTPUT_DIR}/libantlr4-runtime.a)
  if(MINGW)
    set(ANTLR4_SHARED_LIBRARIES
        ${ANTLR4_OUTPUT_DIR}/libantlr4-runtime.dll.a)
    set(ANTLR4_RUNTIME_LIBRARIES
        ${ANTLR4_OUTPUT_DIR}/libantlr4-runtime.dll)
  elseif(CYGWIN)
    set(ANTLR4_SHARED_LIBRARIES
        ${ANTLR4_OUTPUT_DIR}/libantlr4-runtime.dll.a)
    set(ANTLR4_RUNTIME_LIBRARIES
        ${ANTLR4_OUTPUT_DIR}/cygantlr4-runtime-4.10.1.dll)
  elseif(APPLE)
    set(ANTLR4_RUNTIME_LIBRARIES
        ${ANTLR4_OUTPUT_DIR}/libantlr4-runtime.dylib)
  else()
    set(ANTLR4_RUNTIME_LIBRARIES
        ${ANTLR4_OUTPUT_DIR}/libantlr4-runtime.so)
  endif()
endif()

if(${CMAKE_GENERATOR} MATCHES ".* Makefiles")
  # This avoids
  # 'warning: jobserver unavailable: using -j1. Add '+' to parent make rule.'
  set(ANTLR4_BUILD_COMMAND $(MAKE))
elseif(${CMAKE_GENERATOR} MATCHES "Visual Studio.*")
  set(ANTLR4_BUILD_COMMAND
      ${CMAKE_COMMAND}
          --build .
          --config $(Configuration)
          --target)
elseif(${CMAKE_GENERATOR} MATCHES "Xcode.*")
  set(ANTLR4_BUILD_COMMAND
      ${CMAKE_COMMAND}
          --build .
          --config $(CONFIGURATION)
          --target)
else()
  set(ANTLR4_BUILD_COMMAND
      ${CMAKE_COMMAND}
          --build .
          --target)
endif()

if(NOT DEFINED ANTLR4_WITH_STATIC_CRT)
  set(ANTLR4_WITH_STATIC_CRT ON)
endif()

FetchContent_Declare(
    # ExternalProject_Add(
    antlr4_runtime
    GIT_REPOSITORY ${ANTLR4_GIT_REPOSITORY}
    GIT_TAG ${ANTLR4_TAG}
    SOURCE_SUBDIR runtime/Cpp
)

# Separate build step as rarely people want both
set(ANTLR4_BUILD_DIR ${ANTLR4_ROOT})
if(${CMAKE_VERSION} VERSION_GREATER_EQUAL "3.14.0")
  # CMake 3.14 builds in above's SOURCE_SUBDIR when BUILD_IN_SOURCE is true
  set(ANTLR4_BUILD_DIR ${ANTLR4_ROOT}/runtime/Cpp)
endif()

FetchContent_MakeAvailable(antlr4_runtime)
target_include_directories(antlr4_static PUBLIC ${ANTLR4_INCLUDE_DIRS})

