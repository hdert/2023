#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include <ctype.h>
#include "Stack.h"
#include "main.h"

double check_valid_operator(char operator)
{
    switch (operator)
    {
    case ADDITION:
        return 1;
    case SUBTRACTION:
        return 1;
    case DIVISION:
        return 1;
        break;
    case MULTIPLICATION:
        return 1;
        break;
    case EXPONENTIATION:
        return 1;
        break;
    case MODULUS:
        return 1;
        break;
    case LEFT_PAREN:
        return 1;
        break;
    case RIGHT_PAREN:
        return 1;
        break;
    default:
        printf("That wasn't a valid operator\n");
        return 0;
    }
}

void get_input_validate(char *buffer, int bufferSize)
{
    bool isOperator = true;
    // Start true to check if it starts with an operator
    int paren_counter = 0;
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
            if (buffer[i] == LEFT_PAREN)
            {
                // We don't enforce that isOperator is true as
                // We could be at the start of the equation.
                paren_counter++;
                continue;
            }
            if (buffer[i] == RIGHT_PAREN)
            {
                if (isOperator)
                {
                    printf("You cannot end a paren with an operator!\n");
                    successful == false;
                    break;
                }
                paren_counter--;
                if (paren_counter < 0)
                {
                    // If paren_counter goes below zero at any point,
                    // parentheses are mismatched. This avoids cases like:
                    // 21 + 2 ) * ( 5 / 6
                    printf("Mismatched parentheses!\n");
                    successful == false;
                    break;
                }
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
            if (!check_valid_operator(buffer[i]))
            {
                printf("You have entered an invalid operator!\n");
                successful = false;
                break;
            }
            isOperator = true;
            // Break triggers this which upholds that the start of
            // equation this should be set to true
        }
        // Check the input doesn't finish with an operator
        if (isOperator)
        {
            printf("You cannot finish with an operator!\n");
            successful = false;
        }
    }
}

void infix_to_postfix(char *input, char *output)
{
    Stack STACK = {NULL, 0};

    Stack_free(&STACK);
}

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