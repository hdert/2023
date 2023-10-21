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

double check_valid_operator(char operator);

bool validate_input(char *buffer, int bufferSize);

void get_input_validate(char *buffer, int bufferSize);

#endif // CALCULATORLIB_H