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
            // Failure message already printed by infix_to_postfix
            // We should break here as all infix_to_postfix errors are fatal
            // and the cause of the system/code not the user.
            break;
        }

        if (!evaluate_postfix(output, &result))
        {
            // We continue here as all errors are user caused, so we can just
            // ask them again for input.
            continue;
        }

        printf("The result is %.6lf\n", result);
    }
}
