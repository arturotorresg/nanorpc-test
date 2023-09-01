# include(SystemLink.cmake)
# include(LibFuzzer.cmake)
include(CMakeDependentOption)
include(CheckCXXCompilerFlag)

macro(scv_supports_sanitizers)
  if((CMAKE_CXX_COMPILER_ID MATCHES ".*Clang.*" OR CMAKE_CXX_COMPILER_ID MATCHES ".*GNU.*") AND NOT WIN32)
    set(SUPPORTS_UBSAN ON)
  else()
    set(SUPPORTS_UBSAN OFF)
  endif()

  if((CMAKE_CXX_COMPILER_ID MATCHES ".*Clang.*" OR CMAKE_CXX_COMPILER_ID MATCHES ".*GNU.*") AND WIN32)
    set(SUPPORTS_ASAN OFF)
  else()
    set(SUPPORTS_ASAN ON)
  endif()
endmacro()

macro(scv_setup_options)
  option(scv_ENABLE_HARDENING "Enable hardening" ON)
  option(scv_ENABLE_COVERAGE "Enable coverage reporting" OFF)
  cmake_dependent_option(
    scv_ENABLE_GLOBAL_HARDENING
    "Attempt to push hardening options to built dependencies"
    ON
    scv_ENABLE_HARDENING
    OFF)

  scv_supports_sanitizers()

  if(NOT PROJECT_IS_TOP_LEVEL OR scv_PACKAGING_MAINTAINER_MODE)
    option(scv_ENABLE_IPO "Enable IPO/LTO" OFF)
    option(scv_WARNINGS_AS_ERRORS "Treat Warnings As Errors" OFF)
    option(scv_ENABLE_USER_LINKER "Enable user-selected linker" OFF)
    option(scv_ENABLE_SANITIZER_ADDRESS "Enable address sanitizer" OFF)
    option(scv_ENABLE_SANITIZER_LEAK "Enable leak sanitizer" OFF)
    option(scv_ENABLE_SANITIZER_UNDEFINED "Enable undefined sanitizer" OFF)
    option(scv_ENABLE_SANITIZER_THREAD "Enable thread sanitizer" OFF)
    option(scv_ENABLE_SANITIZER_MEMORY "Enable memory sanitizer" OFF)
    option(scv_ENABLE_UNITY_BUILD "Enable unity builds" OFF)
    option(scv_ENABLE_CLANG_TIDY "Enable clang-tidy" OFF)
    option(scv_ENABLE_CPPCHECK "Enable cpp-check analysis" OFF)
    option(scv_ENABLE_PCH "Enable precompiled headers" OFF)
    option(scv_ENABLE_CACHE "Enable ccache" OFF)
  else()
    option(scv_ENABLE_IPO "Enable IPO/LTO" ON)
    option(scv_WARNINGS_AS_ERRORS "Treat Warnings As Errors" ON)
    option(scv_ENABLE_USER_LINKER "Enable user-selected linker" OFF)
    option(scv_ENABLE_SANITIZER_ADDRESS "Enable address sanitizer" ${SUPPORTS_ASAN})
    option(scv_ENABLE_SANITIZER_LEAK "Enable leak sanitizer" OFF)
    option(scv_ENABLE_SANITIZER_UNDEFINED "Enable undefined sanitizer" ${SUPPORTS_UBSAN})
    option(scv_ENABLE_SANITIZER_THREAD "Enable thread sanitizer" OFF)
    option(scv_ENABLE_SANITIZER_MEMORY "Enable memory sanitizer" OFF)
    option(scv_ENABLE_UNITY_BUILD "Enable unity builds" OFF)
    option(scv_ENABLE_CLANG_TIDY "Enable clang-tidy" ON)
    option(scv_ENABLE_CPPCHECK "Enable cpp-check analysis" ON)
    option(scv_ENABLE_PCH "Enable precompiled headers" OFF)
    option(scv_ENABLE_CACHE "Enable ccache" ON)
  endif()

  if(NOT PROJECT_IS_TOP_LEVEL)
    mark_as_advanced(
      scv_ENABLE_IPO
      scv_WARNINGS_AS_ERRORS
      scv_ENABLE_USER_LINKER
      scv_ENABLE_SANITIZER_ADDRESS
      scv_ENABLE_SANITIZER_LEAK
      scv_ENABLE_SANITIZER_UNDEFINED
      scv_ENABLE_SANITIZER_THREAD
      scv_ENABLE_SANITIZER_MEMORY
      scv_ENABLE_UNITY_BUILD
      scv_ENABLE_CLANG_TIDY
      scv_ENABLE_CPPCHECK
      scv_ENABLE_COVERAGE
      scv_ENABLE_PCH
      scv_ENABLE_CACHE)
  endif()

  # scv_check_libfuzzer_support(LIBFUZZER_SUPPORTED)

  # if(LIBFUZZER_SUPPORTED AND(scv_ENABLE_SANITIZER_ADDRESS OR scv_ENABLE_SANITIZER_THREAD OR scv_ENABLE_SANITIZER_UNDEFINED))
  # set(DEFAULT_FUZZER ON)
  # else()
  # set(DEFAULT_FUZZER OFF)
  # endif()

  # option(scv_BUILD_FUZZ_TESTS "Enable fuzz testing executable" ${DEFAULT_FUZZER})
endmacro()

macro(scv_global_options)
  if(scv_ENABLE_IPO)
    include(cmake/InterproceduralOptimization.cmake)
    scv_enable_ipo()
  endif()

  scv_supports_sanitizers()

  # if(scv_ENABLE_HARDENING AND scv_ENABLE_GLOBAL_HARDENING)
  # include(cmake/Hardening.cmake)

  # if(NOT SUPPORTS_UBSAN
  # OR scv_ENABLE_SANITIZER_UNDEFINED
  # OR scv_ENABLE_SANITIZER_ADDRESS
  # OR scv_ENABLE_SANITIZER_THREAD
  # OR scv_ENABLE_SANITIZER_LEAK)
  # set(ENABLE_UBSAN_MINIMAL_RUNTIME FALSE)
  # else()
  # set(ENABLE_UBSAN_MINIMAL_RUNTIME TRUE)
  # endif()

  # message("${scv_ENABLE_HARDENING} ${ENABLE_UBSAN_MINIMAL_RUNTIME} ${scv_ENABLE_SANITIZER_UNDEFINED}")
  # scv_enable_hardening(scv_options ON ${ENABLE_UBSAN_MINIMAL_RUNTIME})
  # endif()
endmacro()

macro(scv_local_options)
  if(PROJECT_IS_TOP_LEVEL)
    include(cmake/StandardProjectSettings.cmake)
  endif()

  add_library(scv_warnings INTERFACE)
  add_library(scv_options INTERFACE)

  if(scv_ENABLE_COVERAGE)
    include(cmake/Tests.cmake)
    scv_enable_coverage(scv_options)
  endif()

  include(cmake/CompilerWarnings.cmake)
  scv_set_project_warnings(
    scv_warnings
    ${scv_WARNINGS_AS_ERRORS}
    ""
    ""
    ""
    "")

  # if(scv_ENABLE_USER_LINKER)
  # include(cmake/Linker.cmake)
  # configure_linker(scv_options)
  # endif()
  include(cmake/Sanitizers.cmake)
  scv_enable_sanitizers(
    scv_options
    ${scv_ENABLE_SANITIZER_ADDRESS}
    ${scv_ENABLE_SANITIZER_LEAK}
    ${scv_ENABLE_SANITIZER_UNDEFINED}
    ${scv_ENABLE_SANITIZER_THREAD}
    ${scv_ENABLE_SANITIZER_MEMORY})

  # set_target_properties(scv_options PROPERTIES UNITY_BUILD ${scv_ENABLE_UNITY_BUILD})
  if(scv_ENABLE_PCH)
    target_precompile_headers(
      scv_options
      INTERFACE
      <vector>
      <string>
      <utility>)
  endif()

  # if(scv_ENABLE_CACHE)
  # include(cmake/Cache.cmake)
  # scv_enable_cache()
  # endif()
  include(cmake/StaticAnalyzers.cmake)

  # TODO: scv_options has no target, think how to do use clang-tidy
  if(scv_ENABLE_CLANG_TIDY)
    scv_enable_clang_tidy(scv_options ${scv_WARNINGS_AS_ERRORS})
  endif()

  if(scv_ENABLE_CPPCHECK)
    scv_enable_cppcheck(${scv_WARNINGS_AS_ERRORS} "" # override cppcheck options
    )
  endif()

  if(scv_WARNINGS_AS_ERRORS)
    check_cxx_compiler_flag("-Wl,--fatal-warnings" LINKER_FATAL_WARNINGS)

    if(LINKER_FATAL_WARNINGS)
      # This is not working consistently, so disabling for now
      # target_link_options(scv_options INTERFACE -Wl,--fatal-warnings)
    endif()
  endif()

  # if(scv_ENABLE_HARDENING AND NOT scv_ENABLE_GLOBAL_HARDENING)
  # include(cmake/Hardening.cmake)

  # if(NOT SUPPORTS_UBSAN
  # OR scv_ENABLE_SANITIZER_UNDEFINED
  # OR scv_ENABLE_SANITIZER_ADDRESS
  # OR scv_ENABLE_SANITIZER_THREAD
  # OR scv_ENABLE_SANITIZER_LEAK)
  # set(ENABLE_UBSAN_MINIMAL_RUNTIME FALSE)
  # else()
  # set(ENABLE_UBSAN_MINIMAL_RUNTIME TRUE)
  # endif()

  # scv_enable_hardening(scv_options OFF ${ENABLE_UBSAN_MINIMAL_RUNTIME})
  # endif()
endmacro()
