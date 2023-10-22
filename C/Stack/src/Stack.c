#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include "LinkedList.h"
#include "Stack.h"

void Stack_print(Stack STACK)
{
    Head HEAD = {STACK.ptr, STACK.length};
    LinkedList_print(HEAD);
}

void Stack_push(Stack *STACK, double value)
{
    Head HEAD = {STACK->ptr, STACK->length};
    LinkedList_add(&HEAD, value, 0);
    STACK->ptr = HEAD.ptr;
    STACK->length = HEAD.length;
}

double Stack_pop(Stack *STACK)
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
double Stack_peek(Stack STACK)
{
    Head HEAD = {STACK.ptr, STACK.length};
    return LinkedList_get(HEAD, 0);
}
