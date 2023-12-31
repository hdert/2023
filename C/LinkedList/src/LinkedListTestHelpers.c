#define MUNIT_ENABLE_ASSERT_ALIASES
#include <stdio.h>
#include "LinkedList.h"
#include "munit.h"
#include "LinkedListTestHelpers.h"
#define MAX(a, b) (a > b) ? a : b

static void LinkedListTest_print_helper(Node *LinkedList, char **running_result, int *resultSize)
{
    int offset;
    offset = snprintf(*running_result, MAX(*resultSize, 0), ", %.0lf", LinkedList->value);
    *running_result += offset;
    *resultSize -= offset;
    if (LinkedList->ptr != nullptr)
    {
        LinkedListTest_print_helper(LinkedList->ptr, running_result, resultSize);
    }
}

void LinkedListTest_print(Head HEAD, char *result, int resultSize)
{
    memset(result, 0, resultSize);
    // Set the buffer empty for each test
    char *running_result = result;
    // Preserve the pointer location of result so we can iterate with snprintf
    int offset;
    if (HEAD.ptr == nullptr)
    {
        offset = snprintf(running_result, MAX(resultSize, 0), "{}");
        running_result += offset;
        resultSize -= offset;
        // In theory, resultSize is guaranteed not to overflow as the offset will only
        // ever be as large as resultSize because of snprintf. Then further
        // snprintf's won't write anything to the result, so it'll look weird
        // but it'll be fine.
        return;
    }
    offset = snprintf(running_result, MAX(resultSize, 0), "{%.0lf", HEAD.ptr->value);
    running_result += offset;
    resultSize -= offset;
    if (HEAD.ptr->ptr != nullptr)
    {
        LinkedListTest_print_helper(HEAD.ptr->ptr, &running_result, &resultSize);
    }
    offset = snprintf(running_result, MAX(resultSize, 0), "}");
    running_result += offset;
    resultSize -= offset;
}

void assert_LinkedList(Head HEAD, char *expectation)
{
    char str_buffer[200] = {};
    LinkedListTest_print(HEAD, str_buffer, sizeof str_buffer);
    assert_string_equal(str_buffer, expectation);
}
