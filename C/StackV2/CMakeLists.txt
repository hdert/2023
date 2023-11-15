cmake_minimum_required(VERSION 3.27)
project(Stack LANGUAGES C)
include(CTest)


add_library(Stack src/Stack.c)

add_library(Munit ../munit/munit.c)
set_property(TARGET Munit PROPERTY C_STANDARD 11)

#add_subdirectory(../munit Munit)

#target_link_libraries(Stack PUBLIC LinkedList)

target_include_directories(Stack PUBLIC
                          "${PROJECT_SOURCE_DIR}/../munit/"
                          )

add_executable(StackTest src/Tests.c)

target_link_libraries(StackTest PUBLIC Stack)
target_link_libraries(StackTest PUBLIC Munit)

target_include_directories(StackTest PUBLIC
                          "${PROJECT_SOURCE_DIR}/../munit/"
                          )

add_test(StackTest StackTest)