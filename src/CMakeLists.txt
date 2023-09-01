project(server)

add_executable(server main.cpp)
target_link_libraries(server rt nanorpc ssl crypto pthread)

get_target_property(compile_defs server COMPILE_DEFINITIONS)
message(STATUS "App compile definitions are ${compile_defs}")
