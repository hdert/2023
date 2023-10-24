#include <stdio.h>
#include <math.h>
#include <stdbool.h>
#include <ctype.h>
// #include <string.h>
// #include <ctype.h>
// #include "Stack.h"
#include "CalculatorLib.h"

int main(void)
{
    double result;
    char input[100];
    char output[100];
    while (true)
    {
        get_input_validate(input, sizeof input - 1);

        if (!infix_to_postfix(input, sizeof input, output, sizeof output))
        {
            // TODO: Failure message
            continue;
        }

        if (!evaluate_postfix(output, &result))
        {
            continue;
        }

        printf("The result is %.6lf\n", result);
    }
}
