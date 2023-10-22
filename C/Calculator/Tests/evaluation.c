#define MUNIT_ENABLE_ASSERT_ALIASES
#include <stdio.h>
#include <math.h>
#include <stdbool.h>
#include <string.h>
#include "munit.h"
#include "CalculatorLib.h"

int test_evaluate()
{

    return 0;
}
int test_evaluate_postfix()
{
    char *cases[] = {
        "10 10 +",
        "20"};
    return 0;
}

int main(void)
{
    test_evaluate();
    test_evaluate_postfix();
    return 0;
}