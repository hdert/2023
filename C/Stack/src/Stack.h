#ifndef STACK_H
#define STACK_H
#include "LinkedList/src/LinkedList.h"

typedef struct Stack
{
    struct Node *ptr;
    int length;
} Stack;

void Stack_print(Stack STACK);

void Stack_add(Stack *STACK, int value);

int Stack_pop(Stack *STACK);

int Stack_peek(Stack STACK);

void Stack_free(Stack *STACK);

#endif // STACK_H