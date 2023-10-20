#define MUNIT_ENABLE_ASSERT_ALIASES
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include "LinkedList.h"
#include "LinkedListTestHelpers.h"
#include "Stack.h"
#include "munit.h"

void assert_Stack(Stack STACK, char *expectation)
{
    Head HEAD = {STACK.ptr, STACK.length};
    assert_LinkedList(HEAD, expectation);
}

int main(void)
{
    char str_buffer[200];
    Stack STACK = {NULL, 0};
    assert_Stack(STACK, "{}");
    assert_int(STACK.length, ==, 0);
    Stack_add(&STACK, 21);
    assert_Stack(STACK, "{21}");
    assert_int(STACK.length, ==, 1);
    Stack_add(&STACK, 19);
    assert_Stack(STACK, "{19, 21}");
    assert_int(STACK.length, ==, 2);
    assert_int(Stack_peek(STACK), ==, 19);
    assert_int(Stack_pop(&STACK), ==, 19);
    assert_Stack(STACK, "{21}");
    assert_int(STACK.length, ==, 1);
    assert_int(Stack_pop(&STACK), ==, 21);
    assert_Stack(STACK, "{}");
    assert_int(STACK.length, ==, 0);
    Stack_add(&STACK, 21);
    Stack_add(&STACK, 22);
    assert_Stack(STACK, "{22, 21}");
    assert_int(STACK.length, ==, 2);
    Stack_free(&STACK);
    assert_Stack(STACK, "{}");
    assert_int(STACK.length, ==, 0);
    return 0;
}