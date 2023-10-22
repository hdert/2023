#ifndef CALCULATORLIB_H
#define CALCULATORLIB_H

typedef enum
{
    ADDITION = '+',
    SUBTRACTION = '-',
    DIVISION = '/',
    // INT_DIVISION = '//',
    MULTIPLICATION = '*',
    EXPONENTIATION = '^',
    // ALT_EXPONENTIATION = '**',
    MODULUS = '%',
    LEFT_PAREN = '(',
    RIGHT_PAREN = ')',
} operators;

double check_valid_operator(char operator, bool quiet);

bool validate_input(char *buffer, int bufferSize);

void get_input_validate(char *buffer, int bufferSize);

void infix_to_postfix(char *input, int inputSize, char *output, int outputSize);

int operator_precedence(char operator);

double evaluate(char operator, double value_1, double value_2);

double evaluate_postfix(char *expression, int expressionSize);

#endif // CALCULATORLIB_H