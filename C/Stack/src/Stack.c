#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include "LinkedList/src/LinkedList.h"
#include "Stack.h"

void Stack_print(Stack STACK)
{
    Head HEAD = {STACK.ptr, STACK.length};
    LinkedList_print(HEAD);
}

void Stack_add(Stack *STACK, int value)
{
    Head HEAD = {STACK->ptr, STACK->length};
    LinkedList_add(&HEAD, value, 0);
    STACK->ptr = HEAD.ptr;
    STACK->length = HEAD.length;
}

int Stack_pop(Stack *STACK)
{
    Head HEAD = {STACK->ptr, STACK->length};
    int result = LinkedList_pop(&HEAD, 0);
    STACK->ptr = HEAD.ptr;
    STACK->length = HEAD.length;
    return result;
}

void Stack_free(Stack *STACK)
{
    Head HEAD = {STACK->ptr, STACK->length};
    LinkedList_free(&HEAD);
    STACK->ptr = HEAD.ptr;
    STACK->length = HEAD.length;
}
int Stack_peek(Stack STACK)
{
    Head HEAD = {STACK.ptr, STACK.length};
    return LinkedList_get(HEAD, 0);
}

// static int main(void)
// {
//     Stack STACK = {NULL, 0};
//     Stack_print(STACK);                   // {}
//     printf("Length: %d\n", STACK.length); // Length: 0
//     Stack_add(&STACK, 21);
//     Stack_print(STACK);                   // {21}
//     printf("Length: %d\n", STACK.length); // Length: 1
//     Stack_add(&STACK, 19);
//     Stack_print(STACK);                   // {19, 21}
//     printf("Length: %d\n", STACK.length); // Length: 2
//     printf("%d", Stack_peek(STACK));      // 19
//     printf("%d", Stack_pop(&STACK));      // 19
//     Stack_print(STACK);                   // {21}
//     printf("Length: %d\n", STACK.length); // Length: 1
//     printf("%d", Stack_pop(&STACK));      // 21
//     Stack_print(STACK);                   // {}
//     printf("Length: %d\n", STACK.length); // Length: 0
//     Stack_add(&STACK, 21);
//     Stack_add(&STACK, 22);
//     Stack_print(STACK);                   // {22, 21}
//     printf("Length: %d\n", STACK.length); // Length: 2
//     Stack_free(&STACK);
//     Stack_print(STACK);                   // {}
//     printf("Length: %d\n", STACK.length); // Length: 0
//     return 0;
// }