include(CTest)

add_executable(InputTest input.c)

include_directories(
                   "${PROJECT_SOURCE_DIR}/../munit/"
                   "${PROJECT_SOURCE_DIR}/src/"
                   )

target_link_libraries(InputTest PUBLIC Munit)
target_link_libraries(InputTest PUBLIC CalculatorLib)

add_test(InputTest InputTest)