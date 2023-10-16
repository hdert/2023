#include <stdio.h>

int main()
{
    int input_1;
    int input_2;
    printf("Type a number: ");
    scanf("%d", &input_1);
    printf("Type a second number: ");
    scanf("%d", &input_2);
    printf("The sum is %d\n", input_1 + input_2);
    printf("%d\n", input_1);
    printf("%d\n", input_2);
    return 0;
}