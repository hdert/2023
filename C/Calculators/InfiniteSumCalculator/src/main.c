#include <stdio.h>
#include <string.h>

int main()
{
    const int INPUT_ARRAY_SIZE = 100;
    int input[INPUT_ARRAY_SIZE];
    memset(input, 0, sizeof input); // Explicitly set array values
    char buffer[100];
    printf("Type any amount of numbers you want to sum, finishing with a blank line:\n");
    for (int i = 0; i < INPUT_ARRAY_SIZE; i++)
    {
        fgets(buffer, sizeof buffer, stdin);
        if (sscanf(buffer, "%d", &input[i]) != 1)
        {
            input[i] = 0;
            break;
        }
    }
    int sum = 0;
    for (int i = 0; i < INPUT_ARRAY_SIZE; i++)
    {
        // printf("%d ", input[i]);
        sum += input[i];
    }
    printf("The sum is %d", sum);
    return 0;
}