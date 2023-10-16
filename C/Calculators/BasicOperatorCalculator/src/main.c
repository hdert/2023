#include <stdio.h>
#include <math.h>

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

int main()
{
    char operator;
    float result;
    char buffer[100];
    while (1)
    {
        printf("Enter an operator: ");
        fgets(buffer, sizeof buffer, stdin);
        if (sscanf(buffer, "%c", &operator) != 1)
        {
            printf("That wasn't a valid operator\n");
            continue;
        }
        switch (operator)
        {
        case ADDITION:
            break;
        case SUBTRACTION:
            break;
        case DIVISION:
            break;
        case MULTIPLICATION:
            break;
        case EXPONENTIATION:
            break;
        case MODULUS:
            break;
        default:
            printf("That wasn't a valid operator\n");
            continue;
        }
        break;
    }
    int input_1, input_2;
    printf("Enter the first number: ");
    scanf("%d", &input_1);
    printf("Enter the second number: ");
    scanf("%d", &input_2);
    switch (operator)
    {
    case ADDITION:
        result = input_1 + input_2;
        break;
    case SUBTRACTION:
        result = input_1 - input_2;
        break;
    case DIVISION:
        if (input_2 == 0)
        {
            printf("Cannot divide by 0");
            return 1;
        }
        result = (float)input_1 / input_2;
        break;
    case MULTIPLICATION:
        result = input_1 * input_2;
        break;
    case EXPONENTIATION:
        result = powf(input_1, input_2);
        break;
    case MODULUS:
        result = input_1 % input_2;
        break;
    default:
        printf("UB");
        return 99;
    }
    printf("The result is %.3f", result);
    return 0;
}