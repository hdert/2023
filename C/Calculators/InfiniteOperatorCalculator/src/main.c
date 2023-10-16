#include <stdio.h>
#include <math.h>
#include <stdbool.h>

enum operators
{
    ADDITION = '+',
    SUBTRACTION = '-',
    DIVISION = '/',
    // INT_DIVISION = '//',
    MULTIPLICATION = '*',
    EXPONENTIATION = '^',
    // ALT_EXPONENTIATION = '**',
    MODULUS = '%',
};

double evaluate(char operator, int value_1, int value_2)
{
    switch (operator)
    {
    case ADDITION:
        return value_1 + value_2;
    case SUBTRACTION:
        return value_1 - value_2;
    case DIVISION:
        if (value_2 == 0)
        {
            printf("Cannot divide by 0");
            return 1;
        }
        return (double)value_1 / value_2;
        break;
    case MULTIPLICATION:
        return value_1 * value_2;
        break;
    case EXPONENTIATION:
        return pow(value_1, value_2); // Broken, or maybe not?
        break;
    case MODULUS:
        if (value_2 == 0)
        {
            printf("Cannot divide by 0");
            return 1;
        }
        return value_1 % value_2;
        break;
    default:
        printf("That wasn't a valid operator\n");
        return 0;
    }
}

char get_operator()
{
    char operator;
    double result;
    char buffer[100];
    while (true)
    {
        printf("Enter an operator: ");
        fgets(buffer, sizeof buffer, stdin);
        if (sscanf(buffer, "%c", &operator) != 1)
        {
            printf("That wasn't a valid operator\n");
            continue;
        }
        result = evaluate(operator, 1, 2);
        if (result != 0)
        {
            return operator;
        }
    }
}

int get_number(int *input)
{
    printf("Number: ");
    char buffer[100];
    fgets(buffer, sizeof buffer, stdin);
    return sscanf(buffer, "%d", input) == 1;
}

int main()
{
    char operator;
    double result;
    int input;
    if (get_number(&input))
    {
        result = input;
    }
    else
    {
        return 1;
    }
    while (true)
    {
        operator= get_operator();
        if (!get_number(&input))
        {
            break;
        }
        result = evaluate(operator, result, input);
    }
    printf("The result is %.3lf", result);
    return 0;
}