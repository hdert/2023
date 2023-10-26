#include <stdio.h>
#include <stdlib.h>
#include "LinkedList.h"
#include "Stack.h"

void Stack_print(Stack STACK)
{
    LinkedList_print(*((Head *)&STACK));
}

bool Stack_push(Stack *STACK, double value)
{
    return LinkedList_add((Head *)STACK, value, 0);
}

double Stack_pop(Stack *STACK)
{
    return LinkedList_pop((Head *)STACK, 0);
}

void Stack_free(Stack *STACK)
{
    LinkedList_free((Head *)STACK);
}
double Stack_peek(Stack STACK)
{
    return LinkedList_get(*((Head *)&STACK), 0);
}
