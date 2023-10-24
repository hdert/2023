#define MUNIT_ENABLE_ASSERT_ALIASES
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include "LinkedList.h"
#include "munit.h"
#include "LinkedListTestHelpers.h"

static void LinkedListTest_print_helper(Node *LinkedList, char **running_result)
{
    *running_result += sprintf(*running_result, ", %.0lf", LinkedList->value);
    if (LinkedList->ptr != NULL)
    {
        LinkedListTest_print_helper(LinkedList->ptr, running_result);
    }
}

void LinkedListTest_print(Head HEAD, char *result, unsigned long resultSize)
{ // TODO: There are serious problems with these functions
    memset(result, 0, resultSize);
    // Set the buffer empty for each test
    char *running_result = result;
    // Preserve the pointer location of result so we can iterate with sprintf
    if (HEAD.ptr == NULL)
    {
        running_result += sprintf(running_result, "{}");
        return;
    }
    running_result += sprintf(running_result, "{%.0lf", HEAD.ptr->value);
    if (HEAD.ptr->ptr != NULL)
    {
        LinkedListTest_print_helper(HEAD.ptr->ptr, &running_result);
    }
    running_result += sprintf(running_result, "}");
}

void assert_LinkedList(Head HEAD, char *expectation)
{
    char str_buffer[200];
    LinkedListTest_print(HEAD, str_buffer, sizeof str_buffer);
    assert_string_equal(str_buffer, expectation);
}
