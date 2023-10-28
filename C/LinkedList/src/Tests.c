#define MUNIT_ENABLE_ASSERT_ALIASES
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "LinkedList.h"
#include "munit.h"
#include "LinkedListTestHelpers.h"

static void assert_LinkedList_print_no_overflow(void)
{
    Head HEAD = {};
    int i = 100;
    while (i--)
    {
        assert_true(LinkedList_append(&HEAD, 10000));
    }
    assert_int(HEAD.length, ==, 100);
    char str_buffer[300] = {};
    LinkedListTest_print(HEAD, str_buffer, 200);
    assert_string_not_equal(str_buffer, "{10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000, 10000}");
    i = 100;
    while (--i)
    {
        assert_char(str_buffer[300 - i], ==, '\000');
    }
}

int main(void)
{
    Head HEAD = {};
    assert_true(LinkedList_append(&HEAD, 11));
    assert_LinkedList(HEAD, "{11}");
    assert_int(HEAD.length, ==, 1);
    assert_true(LinkedList_append(&HEAD, 12));
    assert_LinkedList(HEAD, "{11, 12}");
    assert_int(HEAD.length, ==, 2);
    int nums[] = {1, 2, 3, 4, 5, 6, 7, 8, 12, 3, 123, 532, 643, 13};
    for (unsigned int i = 0; i < sizeof nums / sizeof(int); i++)
    {
        assert_true(LinkedList_append(&HEAD, nums[i]));
    }
    assert_LinkedList(HEAD, "{11, 12, 1, 2, 3, 4, 5, 6, 7, 8, 12, 3, 123, 532, 643, 13}");
    assert_int(HEAD.length, ==, 16);
    assert_int(LinkedList_pop(&HEAD, 0), ==, 11);
    assert_LinkedList(HEAD, "{12, 1, 2, 3, 4, 5, 6, 7, 8, 12, 3, 123, 532, 643, 13}");
    assert_int(HEAD.length, ==, 15);
    assert_int(LinkedList_pop(&HEAD, 1), ==, 1);
    assert_LinkedList(HEAD, "{12, 2, 3, 4, 5, 6, 7, 8, 12, 3, 123, 532, 643, 13}");
    assert_int(HEAD.length, ==, 14);
    assert_int(LinkedList_pop(&HEAD, HEAD.length - 1), ==, 13);
    assert_LinkedList(HEAD, "{12, 2, 3, 4, 5, 6, 7, 8, 12, 3, 123, 532, 643}");
    assert_int(HEAD.length, ==, 13);
    assert_int(LinkedList_get(HEAD, 0), ==, 12);
    assert_int(LinkedList_get(HEAD, 1), ==, 2);
    assert_int(LinkedList_get(HEAD, HEAD.length - 1), ==, 643);
    assert_int(LinkedList_get(HEAD, HEAD.length), ==, 0);
    int index;
    assert_true(LinkedList_find(HEAD, 12, &index));
    assert_int(index, ==, 0);
    assert_true(LinkedList_find(HEAD, 643, &index));
    assert_int(index, ==, 12);
    assert_false(LinkedList_find(HEAD, 0, &index));
    assert_int(index, ==, 12);

    // ****************** Empty_HEAD ******************

    Head Empty_HEAD = {};
    assert_LinkedList(Empty_HEAD, "{}");
    assert_int(Empty_HEAD.length, ==, 0);
    assert_int(LinkedList_get(Empty_HEAD, 1), ==, 0);
    assert_int(LinkedList_get(Empty_HEAD, 1), ==, 0);
    assert_true(LinkedList_append(&Empty_HEAD, 121));
    assert_LinkedList(Empty_HEAD, "{121}");
    assert_int(Empty_HEAD.length, ==, 1);
    assert_int(LinkedList_pop(&Empty_HEAD, 0), ==, 121);
    assert_LinkedList(Empty_HEAD, "{}");
    assert_int(Empty_HEAD.length, ==, 0);
    assert_true(LinkedList_append(&Empty_HEAD, 1));
    assert_true(LinkedList_append(&Empty_HEAD, 2));
    assert_LinkedList(Empty_HEAD, "{1, 2}");
    assert_int(Empty_HEAD.length, ==, 2);
    assert_int(LinkedList_pop(&Empty_HEAD, Empty_HEAD.length), ==, 0); // Index out of bounds!
    assert_int(LinkedList_pop(&Empty_HEAD, Empty_HEAD.length - 1), ==, 2);
    assert_LinkedList(Empty_HEAD, "{1}");
    assert_int(Empty_HEAD.length, ==, 1);
    LinkedList_get(Empty_HEAD, 1); // Index out of bounds!
    assert_int(LinkedList_get(Empty_HEAD, 1), ==, 0);
    assert_int(LinkedList_pop(&Empty_HEAD, Empty_HEAD.length - 1), ==, 1);
    assert_LinkedList(Empty_HEAD, "{}");
    assert_int(Empty_HEAD.length, ==, 0);
    assert_int(LinkedList_pop(&Empty_HEAD, Empty_HEAD.length - 1), ==, 0); // Linked list empty!
    assert_false(LinkedList_find(Empty_HEAD, 0, &index));
    assert_int(index, ==, 0);
    assert_true(LinkedList_add(&Empty_HEAD, 1, 0));
    assert_true(LinkedList_add(&Empty_HEAD, 2, 0));
    assert_LinkedList(Empty_HEAD, "{2, 1}");
    assert_true(LinkedList_add(&Empty_HEAD, 3, Empty_HEAD.length));
    assert_LinkedList(Empty_HEAD, "{2, 1, 3}");
    assert_true(LinkedList_add(&Empty_HEAD, 4, 1));
    assert_LinkedList(Empty_HEAD, "{2, 4, 1, 3}");
    assert_int(LinkedList_pop(&Empty_HEAD, 0), ==, 2);
    assert_LinkedList(Empty_HEAD, "{4, 1, 3}");
    assert_int(LinkedList_pop(&Empty_HEAD, 0), ==, 4);
    assert_int(LinkedList_pop(&Empty_HEAD, 0), ==, 1);
    assert_int(LinkedList_pop(&Empty_HEAD, 0), ==, 3);
    assert_true(LinkedList_add(&Empty_HEAD, 5, Empty_HEAD.length));
    assert_LinkedList(Empty_HEAD, "{5}");

    // ****************** MemLeak_HEAD ******************

    Head MemLeak_HEAD = {};
    for (int i = 0; i < 100; i++)
    {
        assert_true(LinkedList_append(&MemLeak_HEAD, 1));
        assert_int(LinkedList_pop(&MemLeak_HEAD, 0), ==, 1);
    }
    for (int i = 0; i < 100; i++)
    {
        assert_true(LinkedList_append(&MemLeak_HEAD, 1));
    }
    LinkedList_free(&HEAD);
    LinkedList_free(&Empty_HEAD);
    LinkedList_free(&MemLeak_HEAD);
    assert_null(HEAD.ptr);
    assert_int(HEAD.length, ==, 0);
    assert_LinkedList(Empty_HEAD, "{}");
    assert_LinkedList_print_no_overflow();
    return 0;
}
