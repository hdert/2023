include(CTest)

add_executable(InputTest input.c)
add_executable(ConversionTest conversion.c)
add_executable(EvaluationTest evaluation.c)

include_directories(
                   "${PROJECT_SOURCE_DIR}/../munit/"
                   "${PROJECT_SOURCE_DIR}/src/"
                   )

target_link_libraries(InputTest PUBLIC Munit)
target_link_libraries(InputTest PUBLIC CalculatorLib)
target_link_libraries(InputTest PUBLIC m)

target_link_libraries(ConversionTest PUBLIC Munit)
target_link_libraries(ConversionTest PUBLIC CalculatorLib)
target_link_libraries(ConversionTest PUBLIC m)

target_link_libraries(EvaluationTest PUBLIC Munit)
target_link_libraries(EvaluationTest PUBLIC CalculatorLib)
target_link_libraries(EvaluationTest PUBLIC m)

add_test(InputTest InputTest)
add_test(ConversionTest ConversionTest)
add_test(EvaluationTest EvaluationTest)