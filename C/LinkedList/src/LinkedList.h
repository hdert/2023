#ifndef LINKEDLIST_H
#define LINKEDLIST_H

typedef struct Node
{
    int value;
    struct Node *ptr;
} Node;

typedef struct Head
{
    struct Node *ptr;
    int length;
} Head;

void LinkedList_print(Head Head);

void LinkedList_append(Head *HEAD, int value);

int LinkedList_pop(Head *HEAD, int index);

void LinkedList_free(Head *HEAD);

int LinkedList_get(Head HEAD, int index);

bool LinkedList_find(Head HEAD, int key, int *index);

#endif // LINKEDLIST_H