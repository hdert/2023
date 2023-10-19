cmake_minimum_required(VERSION 3.27)

project(Stack LANGUAGES C)

add_library(Stack src/Stack.c)

add_subdirectory(../LinkedList LinkedList)

#add_subdirectory(../munit Munit)

target_link_libraries(Stack PUBLIC LinkedList)

target_link_libraries(Stack PUBLIC Munit)

target_include_directories(Stack PUBLIC
                          "${PROJECT_SOURCE_DIR}/../LinkedList/src"
                          "${PROJECT_SOURCE_DIR}/../munit/"
                          )