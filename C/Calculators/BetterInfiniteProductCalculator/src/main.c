#include <stdio.h>

int main()
{
    int input;
    int product = 1;
    char buffer[100];
    printf("Type any amount of numbers you want the product of, finishing with a blank line:\n");
    while (1)
    {
        fgets(buffer, sizeof buffer, stdin);
        if (sscanf(buffer, "%d", &input) != 1)
        {
            break;
        }
        product *= input;
    }
    printf("The product is %d", product);
    return 0;
}