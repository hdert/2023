#include <stdio.h>
#include <stdlib.h>
#include "LinkedList.h"
#include "Stack.h"

void Stack_print(Stack STACK)
{
    Head HEAD = {.ptr = STACK.ptr, .length = STACK.length};
    LinkedList_print(HEAD);
}

bool Stack_push(Stack *STACK, double value)
{
    Head HEAD = {.ptr = STACK->ptr, .length = STACK->length};
    if (!LinkedList_add(&HEAD, value, 0))
    {
        return false;
    }
    STACK->ptr = HEAD.ptr;
    STACK->length = HEAD.length;
    return true;
}

double Stack_pop(Stack *STACK)
{
    Head HEAD = {.ptr = STACK->ptr, .length = STACK->length};
    double result = LinkedList_pop(&HEAD, 0);
    STACK->ptr = HEAD.ptr;
    STACK->length = HEAD.length;
    return result;
}

void Stack_free(Stack *STACK)
{
    Head HEAD = {.ptr = STACK->ptr, .length = STACK->length};
    LinkedList_free(&HEAD);
    STACK->ptr = HEAD.ptr;
    STACK->length = HEAD.length;
}
double Stack_peek(Stack STACK)
{
    Head HEAD = {.ptr = STACK.ptr, .length = STACK.length};
    return LinkedList_get(HEAD, 0);
}
