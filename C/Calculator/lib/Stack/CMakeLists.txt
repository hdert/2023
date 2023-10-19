add_library(Stack src/Stack.c)

add_subdirectory(lib/LinkedList)

target_link_libraries(Stack PUBLIC LinkedList)

target_include_directories(Stack PUBLIC
                          "${PROJECT_SOURCE_DIR}/lib/Stack/lib/LinkedList/src"
                          )