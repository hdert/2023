#include <stdio.h>
#include <stdbool.h>
// #include <string.h>
// #include <ctype.h>
// #include "Stack.h"
#include "CalculatorLib.h"

int main(void)
{
    double result;
    char input[100];
    while (true)
    {
        get_input_validate(input, sizeof input - 1);

        // Calculate

        printf("The result is %.3lf\n", result);
    }

    return 0;
}