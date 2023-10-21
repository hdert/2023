cmake_minimum_required(VERSION 3.27)
project(Stack LANGUAGES C)
include(CTest)


add_library(Stack src/Stack.c)

add_subdirectory(../LinkedList LinkedList)

#add_subdirectory(../munit Munit)

target_link_libraries(Stack PUBLIC LinkedList)

target_include_directories(Stack PUBLIC
                          "${PROJECT_SOURCE_DIR}/../LinkedList/src"
                          "${PROJECT_SOURCE_DIR}/../munit/"
                          )

add_executable(StackTest src/Tests.c)

target_link_libraries(StackTest PUBLIC Stack)
target_link_libraries(StackTest PUBLIC LinkedList)
target_link_libraries(StackTest PUBLIC LinkedListTestHelpers)
target_link_libraries(StackTest PUBLIC Munit)

target_include_directories(StackTest PUBLIC
                          "${PROJECT_SOURCE_DIR}/../LinkedList/src"
                          "${PROJECT_SOURCE_DIR}/../munit/"
                          )

add_test(StackTest StackTest)