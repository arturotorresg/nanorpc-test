cmake_minimum_required(VERSION 3.16.0)
project(nanorpc-test VERSION 0.1.0)

set(CMAKE_CXX_STANDARD 17)

include_directories(include)
link_directories(${CMAKE_SOURCE_DIR}/lib)

add_executable(server main.cpp)
target_link_libraries(server rt nanorpc ssl crypto pthread)
