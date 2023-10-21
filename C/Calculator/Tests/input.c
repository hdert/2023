#define MUNIT_ENABLE_ASSERT_ALIASES
#include <stdbool.h>
#include <string.h>
#include "munit.h"
#include "CalculatorLib.h"

int test_check_valid_operator()
{
    assert_true(check_valid_operator('+'));
    assert_true(check_valid_operator('-'));
    assert_true(check_valid_operator('/'));
    assert_true(check_valid_operator('*'));
    assert_true(check_valid_operator('^'));
    assert_true(check_valid_operator('%'));
    assert_true(check_valid_operator('('));
    assert_true(check_valid_operator(')'));
    assert_false(check_valid_operator('a'));
    assert_false(check_valid_operator('1'));
    assert_false(check_valid_operator('0'));
    assert_false(check_valid_operator('w'));
    assert_false(check_valid_operator('9'));
    assert_false(check_valid_operator('&'));
    return 0;
}

static MunitResult assert_validate_input(char *input)
{
    char buffer[100];
    memset(buffer, 0, sizeof buffer);
    strcpy(buffer, input);
    strcat(buffer, "\n");
    assert_true(validate_input(buffer, sizeof buffer));
    return MUNIT_OK;
}

int test_validate_input()
{
    const char *cases[] = {
        "10+10",
        "10 + 10",
        "    10+10 (20)",
        NULL};
    for (int i = 0; cases[i] != NULL; i++)
    {
        assert_validate_input(cases[i]);
    }
    return 0;
}

int main(void)
{
    test_check_valid_operator();
    test_validate_input();
    return 0;
}