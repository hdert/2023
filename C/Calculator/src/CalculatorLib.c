#include <stdio.h>
#include <math.h>
#include <stdbool.h>
#include <string.h>
#include <ctype.h>
#include "Stack.h"
#include "CalculatorLib.h"

bool check_valid_operator(char operator_char, bool quiet)
{
    switch (operator_char)
    {
    case ADDITION:
        return true;
    case SUBTRACTION:
        return true;
    case DIVISION:
        return true;
    case MULTIPLICATION:
        return true;
    case EXPONENTIATION:
        return true;
    case MODULUS:
        return true;
    case LEFT_PAREN:
        return true;
    case RIGHT_PAREN:
        return true;
    default:
        if (!quiet)
        {
            printf("That wasn't a valid operator\n");
        }
        return false;
    }
}

bool validate_input(char *buffer, unsigned long bufferSize)
{
    bool isOperator = true;
    // Start true to see if the user starts with an operator
    int paren_counter = 0;
    for (unsigned long i = 0; i < bufferSize; i++)
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
            isOperator = true;
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
            buffer[i + 1] = '\000'; // TODO: What if max buffer size?
            break;                  // Do check isOperator
        }
        // Check that operators aren't repeated
        if (isOperator)
        {
            printf("You can't enter sequential operators!\n");
            return false;
        }
        // Check if it is a valid operator
        if (!check_valid_operator(buffer[i], false))
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

void get_input_validate(char *buffer, unsigned long bufferSize)
{
    do
    {
        memset(buffer, 0, bufferSize);
        // Clear for if the user fails the first time
        printf("Enter your equation: ");
        fgets(buffer, (int)bufferSize, stdin);
    } while (!validate_input(buffer, bufferSize));
}

int operator_precedence(char operator_char)
{
    switch (operator_char)
    {
    case (LEFT_PAREN):
        return 1;
    case (ADDITION):
        return 2;
    case (SUBTRACTION):
        return 2;
    case (MULTIPLICATION):
        return 3;
    case (DIVISION):
        return 3;
    case (MODULUS):
        return 3;
    case (EXPONENTIATION):
        return 4;
    case (RIGHT_PAREN):
        return 5;
    default:
        return 0;
    }
}

bool infix_to_postfix(char *input, unsigned long inputSize, char *output, unsigned long outputSize)
{
    Stack STACK = {NULL, 0};
    unsigned long outputCounter = 0;
    for (unsigned long i = 0; i < inputSize && outputCounter < outputSize; i++)
    {
        if (input[i] == '\000')
        {
            break;
        }
        if (input[i] == ' ')
        {
            continue;
        }
        if (isdigit(input[i]))
        {
            output[outputCounter] = input[i];
            outputCounter++;
            continue;
        }
        if (input[i] == LEFT_PAREN)
        {
            if (!Stack_push(&STACK, LEFT_PAREN))
            {
                return false;
            }
            continue;
        }
        if (input[i] == RIGHT_PAREN)
        {
            while (Stack_peek(STACK) != LEFT_PAREN && outputCounter < outputSize)
            {
                output[outputCounter] = ' ';
                outputCounter++;
                output[outputCounter] = (char)Stack_pop(&STACK);
                outputCounter++;
                // strcat(output, (char)Stack_pop(&STACK));
            }
            Stack_pop(&STACK);
            continue;
        }
        while (STACK.length > 0 && operator_precedence((char)Stack_peek(STACK)) >= operator_precedence(input[i]) && outputCounter < outputSize)
        {
            output[outputCounter] = ' ';
            outputCounter++;
            output[outputCounter] = (char)Stack_pop(&STACK);
            outputCounter++;
        }
        output[outputCounter] = ' ';
        outputCounter++;
        if (!Stack_push(&STACK, input[i]))
        {
            return false;
        }
    }

    while (STACK.length > 0 && outputCounter < outputSize)
    {
        output[outputCounter] = ' ';
        outputCounter++;
        output[outputCounter] = (char)Stack_pop(&STACK);
        outputCounter++;
        // strcat(output, (char)Stack_pop(&STACK));
    }
    Stack_free(&STACK);

    if (outputCounter >= outputSize)
    {
        printf("infix_to_postfix: insufficient output buffer size.");
        return false;
    }
}

bool evaluate(char operator_char, double value_1, double value_2, double *result)
{
    switch (operator_char)
    {
    case ADDITION:
        *result = value_1 + value_2;
        return true;
    case SUBTRACTION:
        *result = value_1 - value_2;
        return true;
    case DIVISION:
        if (value_2 == 0)
        {
            printf("Cannot divide by 0\n");
            return false;
        }
        *result = value_1 / value_2;
        return true;
    case MULTIPLICATION:
        *result = value_1 * value_2;
        return true;
    case EXPONENTIATION:
        *result = pow(value_1, value_2);
        return true;
    case MODULUS:
        if (value_2 == 0)
        {
            printf("Cannot divide by 0\n");
            return false;
        }
        *result = fmod(value_1, value_2);
        return true;
    default:
        printf("That wasn't a valid operator\n");
        return false;
    }
}

bool evaluate_postfix(char *expression, double *result)
{
    Stack STACK = {NULL, 0};
    char *token = strtok(expression, " "); // TODO: An array would be better here
    double value;
    while (token != NULL)
    {
        if (check_valid_operator(*token, true))
        {
            value = Stack_pop(&STACK);
            if (!evaluate(*token, Stack_pop(&STACK), value, &value))
            {
                // The condition works because evaluate computes
                // value_1 + value_2 before assigning the
                // result to value, so no weirdness occurs.
                return false;
            }
            if (!Stack_push(&STACK, value))
            {
                return false;
            }
        }
        else
        {
            sscanf(token, "%lf", &value);
            if (!Stack_push(&STACK, value))
            {
                return false;
            }
        }
        token = strtok(NULL, " ");
    }
    *result = Stack_pop(&STACK);
    Stack_free(&STACK);
    return true;
}
