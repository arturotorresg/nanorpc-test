project(server)

add_executable(server main.cpp)
target_link_libraries(server rt nanorpc ssl crypto pthread)
