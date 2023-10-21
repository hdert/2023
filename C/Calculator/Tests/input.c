#define MUNIT_ENABLE_ASSERT_ALIASES
#include <stdbool.h>
#include <string.h>
#include "munit.h"
#include "CalculatorLib.h"

int test_check_valid_operator()
{
    char success_cases[] = {
        '+',
        '-',
        '/',
        '*',
        '^',
        '%',
        '(',
        ')',
        '\000'};
    char fail_cases[] = {
        'a',
        '1',
        '0',
        'w',
        '9',
        '&',
        '\000'};
    for (int i = 0; success_cases[i] != '\000'; i++)
    {
        assert_true(check_valid_operator(success_cases[i]));
    }
    for (int i = 0; fail_cases[i] != NULL; i++)
    {
        assert_false(check_valid_operator(fail_cases[i]));
    }
    return 0;
}

static bool assert_validate_input(char *input, bool expectation)
{
    char buffer[100];
    memset(buffer, 0, sizeof buffer);
    strcpy(buffer, input);
    strcat(buffer, "\n");
    if (expectation)
    {
        assert_true(validate_input(buffer, sizeof buffer));
    }
    else
    {
        assert_false(validate_input(buffer, sizeof buffer));
    }
    return MUNIT_OK;
}

int test_validate_input()
{
    char *success_cases[] = {
        "10+10",
        "10 + 10",
        "    10+10 (20)",
        "10/10",
        "10 / (10)",
        "10(10)",
        "10*(10)",
        "10 * ( 10 ) ",
        "10",
        NULL};
    char *fail_cases[] = {
        "10++10",
        "10(*10)",
        "10(10*)",
        "10*",
        "10(10)*",
        "()",
        "10()",
        NULL};
    for (int i = 0; success_cases[i] != NULL; i++)
    {
        assert_validate_input(success_cases[i], true);
    }
    for (int i = 0; fail_cases[i] != NULL; i++)
    {
        assert_validate_input(fail_cases[i], false);
    }
    return 0;
}

int main(void)
{
    test_check_valid_operator();
    test_validate_input();
    return 0;
}