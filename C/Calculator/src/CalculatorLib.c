#include <stdio.h>
#include <math.h>
#include <stdbool.h>
#include <string.h>
#include <ctype.h>
#include "Stack.h"
#include "CalculatorLib.h"

double check_valid_operator(char operator, bool quiet)
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
        if (!quiet)
        {
            printf("That wasn't a valid operator\n");
        }
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

int operator_precedence(char operator)
{
    switch (operator)
    {
    case (LEFT_PAREN):
        return 1;
        break;
    case (ADDITION):
        return 2;
        break;
    case (SUBTRACTION):
        return 2;
        break;
    case (MULTIPLICATION):
        return 3;
        break;
    case (DIVISION):
        return 3;
        break;
    case (MODULUS):
        return 3;
        break;
    case (EXPONENTIATION):
        return 4;
        break;
    case (RIGHT_PAREN):
        return 5;
        break;
    default:
        return 0;
        break;
    }
}

void infix_to_postfix(char *input, int inputSize, char *output, int outputSize)
{
    Stack STACK = {NULL, 0};
    int outputCounter = 0;
    for (int i = 0; i < inputSize; i++)
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
            // strcat(output, input[i]);
            outputCounter++;
            continue;
        }
        if (input[i] == LEFT_PAREN)
        {
            Stack_push(&STACK, LEFT_PAREN);
            continue;
        }
        if (input[i] == RIGHT_PAREN)
        {
            while (Stack_peek(STACK) != LEFT_PAREN)
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
        while (STACK.length > 0 && operator_precedence(Stack_peek(STACK)) >= operator_precedence(input[i]))
        {
            output[outputCounter] = ' ';
            outputCounter++;
            output[outputCounter] = (char)Stack_pop(&STACK);
            outputCounter++;
            // strcat(output, (char)Stack_pop(&STACK));
        }
        output[outputCounter] = ' ';
        outputCounter++;
        Stack_push(&STACK, input[i]);
    }

    while (STACK.length > 0)
    {
        output[outputCounter] = ' ';
        outputCounter++;
        output[outputCounter] = (char)Stack_pop(&STACK);
        outputCounter++;
        // strcat(output, (char)Stack_pop(&STACK));
    }
    Stack_free(&STACK);
}

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
        return pow(value_1, value_2);
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

double evaluate_postfix(char *expression, int expressionSize)
{
    Stack STACK = {NULL, 0};
    char *token = strtok(expression, " ");
    double value;
    while (token != NULL)
    {
        if (check_valid_operator(*token, true))
        {
            value = Stack_pop(&STACK);
            Stack_push(&STACK, evaluate(*token, Stack_pop(&STACK), value));
        }
        else
        {
            sscanf(token, "%lf", &value);
            Stack_push(&STACK, value);
        }
        token = strtok(NULL, " ");
    }
    value = Stack_pop(&STACK);
    Stack_free(&STACK);
    return value;
}