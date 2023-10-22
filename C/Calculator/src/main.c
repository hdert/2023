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

        infix_to_postfix(input, sizeof input, output, sizeof output);

        result = evaluate_postfix(output, sizeof output);

        printf("The result is %.6lf\n", result);
    }

    return 0;
}