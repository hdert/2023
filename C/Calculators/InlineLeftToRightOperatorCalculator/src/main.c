#include <stdio.h>
#include <math.h>
#include <stdbool.h>
#include <string.h>
#include <ctype.h>

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

double evaluate(char operator, double value_1, double value_2)
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
            printf("Cannot divide by 0\n");
            return 1;
        }
        return value_1 / value_2;
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
            printf("Cannot divide by 0\n");
            return 1;
        }
        return fmod(value_1, value_2);
        break;
    default:
        printf("That wasn't a valid operator\n");
        return 0;
    }
}

void get_input(char *buffer, int bufferSize)
{
    bool isOperator = true;
    bool successful = false;
    while (!successful)
    {
        memset(buffer, 0, bufferSize);
        // Clear for if the user fails the first time
        printf("Enter your equation: ");
        fgets(buffer, bufferSize, stdin);
        successful = true;
        for (int i = 0; i < bufferSize; i++)
        {
            /* Check that character is a number, operator or space,
            and that operators are not consecutive. */
            if (buffer[i] == ' ')
            {
                continue;
            }
            if (isdigit(buffer[i]))
            {
                isOperator = false;
                continue;
            }
            if (buffer[i] == '\n' || buffer[i] == '\r')
            {
                buffer[i] = '\000';
                buffer[i + 1] = '\000'; // What if max buffer size?
                break;
            }
            // Check that operators aren't repeated
            if (isOperator)
            {
                printf("You can't enter sequential operators!\n");
                successful = false;
                break;
            }
            // Check if it is a valid operator
            if (!evaluate(buffer[i], 1, 2))
            {
                printf("You have entered an invalid operator!\n");
                successful = false;
                break;
            }
            isOperator = true;
        }
        // Check the input doesn't finish with an operator
        if (isOperator)
        {
            printf("You cannot finish with an operator!\n");
            successful = false;
        }
    }
}

int getNumber(char *input, int inputSize, int *i)
{
    int number = 0;
    // printf("%d", inputSize);
    // printf("%c", input[*i]);
    for (; *i < inputSize; (*i)++)
    {
        if (!isdigit(input[*i]))
        {
            break;
        }
        number *= 10;
        number += input[*i] - '0';
    }
    return number;
}

char getOperator(char *input, int inputSize, int *i)
{
    char operator;
    for (; *i < inputSize; (*i)++)
    {
        if (input[*i] == ' ')
        {
            continue;
        }
        // This is so getNumber starts where it expects too
        if (isdigit(input[*i]))
        {
            break;
        }
        if (evaluate(input[*i], 1, 2))
        {
            operator= input[*i];
        }
    }
    return operator;
}

double evaluateString(char *input, int inputSize)
{
    double result;
    char operator;
    int i = 0;
    result = getNumber(input, inputSize, &i);
    for (; i < inputSize && input[i] != '\000';)
    {
        operator= getOperator(input, inputSize, &i);
        result = evaluate(operator, result, getNumber(input, inputSize, &i));
    }
    return result;
}

int main(void)
{
    double result;
    char input[100];
    while (true)
    {

        get_input(input, sizeof input - 1);

        result = evaluateString(input, sizeof input - 1);

        printf("The result is %.3lf\n", result);
    }
}