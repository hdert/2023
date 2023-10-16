#include <stdio.h>
#include <string.h>

int main()
{
    const int INPUT_ARRAY_SIZE = 100;
    int input[INPUT_ARRAY_SIZE];
    // memset(input, 1, sizeof input); // This doesn't work!!!
    for (int i = 0; i < INPUT_ARRAY_SIZE; i++)
    {
        input[i] = 1;
    }
    char buffer[100];
    printf("Type any amount of numbers you want the product of, finishing with a blank line:\n");
    for (int i = 0; i < INPUT_ARRAY_SIZE; i++)
    {
        // printf("%d ", input[i]);
        fgets(buffer, sizeof buffer, stdin);
        if (sscanf(buffer, "%d", &input[i]) != 1)
        {
            input[i] = 1;
            break;
        }
    }
    // printf("\n");
    int product = 1;
    for (int i = 0; i < INPUT_ARRAY_SIZE; i++)
    {
        // printf("%d ", input[i]);
        product *= input[i];
    }
    printf("The product is %d", product);
    return 0;
}