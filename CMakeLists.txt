cmake_minimum_required(VERSION 3.16.0)
project(nanorpc-test VERSION 0.1.0)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake)

# CMake rules
include(PreventInSourceBuilds)
include(ProjectOptions)

scv_setup_options()

scv_global_options()

scv_local_options()

# Conan
include(Conan)
set(CONAN_SYSTEM_INCLUDES ON)
conan_cmake_install(PATH_OR_REFERENCE ${CMAKE_SOURCE_DIR}/conanfile.py)
include(${CMAKE_BINARY_DIR}/conanbuildinfo.cmake)
conan_basic_setup(NO_OUTPUT_DIRS)
message("-- Conan libs: " ${CONAN_LIBS})

# include_directories(include)
# link_directories(${CMAKE_SOURCE_DIR}/lib)

# add_executable(server main.cpp)
# target_link_libraries(server rt nanorpc ssl crypto pthread)

add_subdirectory(src)
