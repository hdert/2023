cmake_minimum_required(VERSION 3.27)

project(Calculator LANGUAGES C)

add_subdirectory(lib/Stack)

add_executable(Calculator src/main.c)

target_link_libraries(Calculator PUBLIC Stack)

target_include_directories(Calculator PUBLIC
                          "${PROJECT_BINARY_DIR}"
                          "${PROJECT_SOURCE_DIR}/lib/Stack/src"
                          )