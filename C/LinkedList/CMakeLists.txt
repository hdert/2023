cmake_minimum_required(VERSION 3.27)
project(LinkedList LANGUAGES C)
include(CTest)


add_library(LinkedList src/LinkedList.c)

add_library(Munit ../munit/munit.c)

add_library(LinkedListTestHelpers src/LinkedListTestHelpers.c)

target_include_directories(LinkedListTestHelpers PRIVATE
                          "${PROJECT_SOURCE_DIR}/../munit/"
                          )

add_executable(LinkedListTest src/Tests.c)

target_link_libraries(LinkedListTest PRIVATE LinkedList)
target_link_libraries(LinkedListTest PRIVATE LinkedListTestHelpers)
target_link_libraries(LinkedListTest PRIVATE Munit)

target_include_directories(LinkedListTest PRIVATE
                          "${PROJECT_SOURCE_DIR}/../munit/"
                          )

add_test(LinkedListTest LinkedListTest)