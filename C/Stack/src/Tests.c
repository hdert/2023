#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include "LinkedList/src/LinkedList.h"
#include "Stack.h"

int main(void)
{
    Stack STACK = {NULL, 0};
    Stack_print(STACK);                   // {}
    printf("Length: %d\n", STACK.length); // Length: 0
    Stack_add(&STACK, 21);
    Stack_print(STACK);                   // {21}
    printf("Length: %d\n", STACK.length); // Length: 1
    Stack_add(&STACK, 19);
    Stack_print(STACK);                   // {19, 21}
    printf("Length: %d\n", STACK.length); // Length: 2
    printf("%d\n", Stack_peek(STACK));    // 19
    printf("%d\n", Stack_pop(&STACK));    // 19
    Stack_print(STACK);                   // {21}
    printf("Length: %d\n", STACK.length); // Length: 1
    printf("%d\n", Stack_pop(&STACK));    // 21
    Stack_print(STACK);                   // {}
    printf("Length: %d\n", STACK.length); // Length: 0
    Stack_add(&STACK, 21);
    Stack_add(&STACK, 22);
    Stack_print(STACK);                   // {22, 21}
    printf("Length: %d\n", STACK.length); // Length: 2
    Stack_free(&STACK);
    Stack_print(STACK);                   // {}
    printf("Length: %d\n", STACK.length); // Length: 0
    return 0;
}