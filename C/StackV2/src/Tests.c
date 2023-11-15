#define MUNIT_ENABLE_ASSERT_ALIASES
#include <stdio.h>
#include <stdlib.h>
// #include "LinkedList.h"
// #include "LinkedListTestHelpers.h"
#include "Stack.h"
#include "munit.h"
#define MAX(a, b) (a > b) ? a : b

static void StackTest_print(Stack STACK, char *result, int resultSize)
{
    memset(result, 0, resultSize);
    char *running_result = result;
    int offset;
    offset = snprintf(running_result, MAX(resultSize, 0), "{");
    running_result += offset;
    resultSize -= offset;
    if (STACK.length > 0)
    {
        // printf("%lf", STACK.data[0]);
        offset = snprintf(running_result, MAX(resultSize, 0), "%.0lf", STACK.data[STACK.length - 1]);
        running_result += offset;
        resultSize -= offset;
    }
    for (int i = STACK.length - 2; i >= 0 && i < STACK.max_length; i--)
    {
        // printf(", %lf", STACK.data[i]);
        offset = snprintf(running_result, MAX(resultSize, 0), ", %.0lf", STACK.data[i]);
        running_result += offset;
        resultSize -= offset;
    }
    // printf("}");
    offset = snprintf(running_result, MAX(resultSize, 0), "}");
    running_result += offset;
    resultSize -= offset;
}

static void assert_Stack(Stack STACK, char *expectation)
{
    // Head HEAD = {.ptr = STACK.ptr, .length = STACK.length};
    // assert_LinkedList(HEAD, expectation);
    char str_buffer[200] = {};
    StackTest_print(STACK, str_buffer, sizeof str_buffer);
    assert_string_equal(str_buffer, expectation);
}

static void assert_Stack_print_no_overflow(void)
{
    Stack STACK = {};
    assert_true(Stack_init(&STACK));
    int i = 300;
    while (i--)
    {
        assert_true(Stack_push(&STACK, 10000));
    }
    assert_int(STACK.length, ==, 300);
    assert_int(STACK.max_length, ==, 400);
    char str_buffer[300] = {};
    StackTest_print(STACK, str_buffer, 200);
    assert_string_not_equal(str_buffer, "{10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000}");
    i = 100;
    while (--i)
    {
        assert_char(str_buffer[300 - i], ==, '\000');
    }
}

static void assert_Stack_no_memleak(void)
{
    Stack STACK = {};
    assert_true(Stack_init(&STACK));
    for (int i = 0; i < 300; i++)
    {
        assert_true(Stack_push(&STACK, 1));
        assert_int(Stack_pop(&STACK), ==, 1);
        assert_int(STACK.data[0], ==, 0);
    }
    for (int i = 0; i < 300; i++)
    {
        assert_true(Stack_push(&STACK, 1));
    }
    assert_int(STACK.length, ==, 300);
    assert_int(STACK.max_length, ==, 400);
    Stack_free(&STACK);
    assert_null(STACK.data);
    assert_int(STACK.length, ==, 0);
    assert_int(STACK.max_length, ==, 0);
    assert_Stack(STACK, "{}");
}

int main(void)
{
    Stack STACK = {};
    assert_true(Stack_init(&STACK));
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
    assert_Stack_no_memleak();
    assert_Stack_print_no_overflow();
    return 0;
}