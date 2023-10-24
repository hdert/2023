#ifndef LINKEDLIST_H
#define LINKEDLIST_H
#include <stdbool.h>

typedef struct Node
{
    double value;
    struct Node *ptr;
} Node;

typedef struct Head
{
    struct Node *ptr;
    int length;
} Head;

void LinkedList_print(Head Head);

bool LinkedList_add(Head *HEAD, double value, int index);

bool LinkedList_append(Head *HEAD, double value);

double LinkedList_pop(Head *HEAD, int index);

void LinkedList_free(Head *HEAD);

double LinkedList_get(Head HEAD, int index);

bool LinkedList_find(Head HEAD, double key, int *index);

#endif // LINKEDLIST_H
