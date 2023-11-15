cmake_minimum_required(VERSION 3.27)
project(Calculator LANGUAGES C)
include(CTest)

set(CMAKE_C_STANDARD 23)


add_executable(Calculator src/main.c)

add_library(CalculatorLib src/CalculatorLib.c)

#add_subdirectory(../Stack Stack)
add_subdirectory(../StackV2 Stack)

target_link_libraries(Calculator PUBLIC CalculatorLib)
target_link_libraries(Calculator PUBLIC m)

target_link_libraries(CalculatorLib PUBLIC Stack)

target_include_directories(CalculatorLib PUBLIC
                          "${PROJECT_BINARY_DIR}"
                          "${PROJECT_SOURCE_DIR}/../StackV2/src"
                          )

add_subdirectory(Tests Tests)

target_link_libraries(InputTest PUBLIC CalculatorLib)
