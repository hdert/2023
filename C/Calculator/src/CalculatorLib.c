#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include <ctype.h>
#include "Stack.h"
#include "CalculatorLib.h"

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

bool validate_input(char *buffer, int bufferSize)
{
    bool isOperator = true;
    // Start true to see if the user starts with an operator
    int paren_counter = 0;
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
                return false;
            }
            paren_counter--;
            if (paren_counter < 0)
            {
                // If paren_counter goes below zero at any point,
                // parentheses are mismatched. This avoids cases like:
                // 21 + 2 ) * ( 5 / 6
                printf("Mismatched parentheses!\n");
                return false;
            }
            continue;
        }
        if (buffer[i] == '\n' || buffer[i] == '\r')
        {
            buffer[i] = '\000';
            buffer[i + 1] = '\000'; // What if max buffer size?
            break;                  // Do check isOperator
        }
        // Check that operators aren't repeated
        if (isOperator)
        {
            printf("You can't enter sequential operators!\n");
            return false;
        }
        // Check if it is a valid operator
        if (!check_valid_operator(buffer[i]))
        {
            printf("You have entered an invalid operator!\n");
            return false;
        }
        isOperator = true;
        // Break triggers this which upholds that the start of
        // equation this should be set to true
    }
    // Check the input doesn't finish with an operator
    if (isOperator)
    {
        printf("You cannot finish with an operator!\n");
        return false;
    }
    return true;
}

void get_input_validate(char *buffer, int bufferSize)
{
    do
    {
        memset(buffer, 0, bufferSize);
        // Clear for if the user fails the first time
        printf("Enter your equation: ");
        fgets(buffer, bufferSize, stdin);
    } while (!validate_input(buffer, bufferSize));
}

void infix_to_postfix(char *input, char *output)
{
    Stack STACK = {NULL, 0};

    Stack_free(&STACK);
}