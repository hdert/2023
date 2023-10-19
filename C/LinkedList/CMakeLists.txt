cmake_minimum_required(VERSION 3.27)

project(LinkedList LANGUAGES C)

add_library(LinkedList src/LinkedList.c)

add_library(Munit ../munit/munit.c)

# add_subdirectory(../munit Munit)

target_link_libraries(LinkedList PUBLIC Munit)

target_include_directories(LinkedList PUBLIC
                          "${PROJECT_SOURCE_DIR}/../munit/"
                          )