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
    int input_1, input_2;
    float result;
    printf("Enter the first number: ");
    scanf("%d", &input_1);
    printf("Enter the second number: ");
    scanf("%d", &input_2);
    char operator;
    char buffer[100];
    fgets(buffer, sizeof buffer, stdin); // Clear stdin
    while (1)
    {
        printf("Enter an operator: ");
        fgets(buffer, sizeof buffer, stdin);
        if (sscanf(buffer, " %c", &operator) != 1)
        {
            printf("That wasn't a valid operator\n");
            continue;
        }
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
            if (input_2 == 0)
            {
                printf("Cannot divide by 0");
                return 1;
            }
            result = input_1 % input_2;
            break;
        default:
            printf("That wasn't a valid operator\n");
            continue;
        }
        printf("The result is %.3f", result);
        return 0;
    }
}