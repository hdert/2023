#define MUNIT_ENABLE_ASSERT_ALIASES
#include <stdio.h>
#include <math.h>
#include <stdbool.h>
#include <string.h>
#include "munit.h"
#include "CalculatorLib.h"

int test_infix_to_postfix()
{
    char *success_cases[] = {
        "10+10",
        "10 10 +",
        "10 + 10",
        "10 10 +",
        "    10+10 *(20)",
        "10 10 20 * +",
        "    10+10 (20)",
        "10 1020 +",
        "10/10",
        "10 10 /",
        "10 / (10)",
        "10 10 /",
        "10(10)",
        "1010",
        "10*(10)",
        "10 10 *",
        "10 * ( 10 ) ",
        "10 10 *",
        "10",
        "10",
        "10 + (10 / 2 * 3) + 10",
        "10 10 2 / 3 * + 10 +",
        NULL,
    };
    char output[100];
    for (int i = 0; success_cases[i] != NULL; i += 2)
    {
        memset(output, 0, sizeof output);
        infix_to_postfix(success_cases[i], strlen(success_cases[i]), output, sizeof output);
        // fprintf(stdout, "Input: %s\n", success_cases[i]);
        // fprintf(stdout, "Expected: %s\n", success_cases[i + 1]);
        // fprintf(stdout, "Result: %s\n", output);
        assert_string_equal(output, success_cases[i + 1]);
    }
    return 0;
}

int test_operator_precedence()
{
    assert_int(operator_precedence('+'), ==, 2);
    assert_int(operator_precedence('-'), ==, 2);
    assert_int(operator_precedence('/'), ==, 3);
    assert_int(operator_precedence('*'), ==, 3);
    assert_int(operator_precedence('^'), ==, 4);
    assert_int(operator_precedence('%'), ==, 3);
    assert_int(operator_precedence('('), ==, 1);
    assert_int(operator_precedence(')'), ==, 5);
    assert_int(operator_precedence('a'), ==, 0);
}

int main(void)
{
    test_infix_to_postfix();
    test_operator_precedence();
    return 0;
}