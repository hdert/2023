#define MUNIT_ENABLE_ASSERT_ALIASES
#include <stdio.h>
#include <math.h>
#include <stdbool.h>
#include <string.h>
#include "munit.h"
#include "CalculatorLib.h"

static int test_evaluate(void)
{
    char success_cases[] = {
        '+',
        '-',
        '/',
        '*',
        '^',
        '%',
    };
    double success_cases_numbers[][3] = {
        10,
        10,
        20,
        10,
        10,
        0,
        10,
        10,
        1,
        10,
        10,
        100,
        10,
        2,
        100,
        30,
        10,
        0,
    };
    char fail_cases[] = {
        '/',
        '%',
        'a',
        '&',
        '1',
    };
    double fail_cases_numbers[][2] = {
        10,
        0,
        10,
        0,
        10,
        10,
        10,
        10,
        10,
        10,
    };
    double result;
    for (int i = 0; i < sizeof success_cases; i++)
    {
        assert_true(evaluate(success_cases[i], success_cases_numbers[i][0], success_cases_numbers[i][1], &result));
        assert_int(result, ==, success_cases_numbers[i][2]);
    }
    result = 0;
    for (int i = 0; i < sizeof fail_cases; i++)
    {
        assert_false(evaluate(fail_cases[i], fail_cases_numbers[i][0], fail_cases_numbers[i][1], &result));
        assert_int(result, ==, 0);
    }
    return 0;
}
static int test_evaluate_postfix(void)
{
    char *success_cases[] = {
        // Doesn't work because strings aren't modifiable
        "10 10 +",
        "10 10 -",
        "10 10 /",
        "10 2 3 3 * + + 10 -",
        NULL,
    };
    double success_results[] = {
        20,
        0,
        1,
        11,
    };
    char *fail_cases[] = {
        "10 0 /",
        "10 0 %",
        "10 10 10 - /",
        "10 10 10 - %",
        NULL,
    };
    double result;
    char string[100];
    for (int i = 0; success_cases[i] != NULL; i++)
    {
        strcpy(string, success_cases[i]);
        assert_true(evaluate_postfix(string, &result));
        assert_int(result, ==, success_results[i]);
    }
    result = 0;
    for (int i = 0; fail_cases[i] != NULL; i++)
    {
        strcpy(string, fail_cases[i]);
        assert_false(evaluate_postfix(string, &result));
        assert_int(result, ==, 0);
    }
    return 0;
}

int main(void)
{
    test_evaluate();
    test_evaluate_postfix();
    return 0;
}
