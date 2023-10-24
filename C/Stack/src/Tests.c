#define MUNIT_ENABLE_ASSERT_ALIASES
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include "LinkedList.h"
#include "LinkedListTestHelpers.h"
#include "Stack.h"
#include "munit.h"

static void assert_Stack(Stack STACK, char *expectation)
{
    Head HEAD = {STACK.ptr, STACK.length};
    assert_LinkedList(HEAD, expectation);
}

int main(void)
{
    Stack STACK = {NULL, 0};
    assert_Stack(STACK, "{}");
    assert_int(STACK.length, ==, 0);
    assert_true(Stack_push(&STACK, 21));
    assert_Stack(STACK, "{21}");
    assert_int(STACK.length, ==, 1);
    assert_true(Stack_push(&STACK, 19));
    assert_Stack(STACK, "{19, 21}");
    assert_int(STACK.length, ==, 2);
    assert_int(Stack_peek(STACK), ==, 19);
    assert_int(Stack_pop(&STACK), ==, 19);
    assert_Stack(STACK, "{21}");
    assert_int(STACK.length, ==, 1);
    assert_int(Stack_pop(&STACK), ==, 21);
    assert_Stack(STACK, "{}");
    assert_int(STACK.length, ==, 0);
    assert_true(Stack_push(&STACK, 21));
    assert_true(Stack_push(&STACK, 22));
    assert_Stack(STACK, "{22, 21}");
    assert_int(STACK.length, ==, 2);
    Stack_free(&STACK);
    assert_Stack(STACK, "{}");
    assert_int(STACK.length, ==, 0);
    return 0;
}
