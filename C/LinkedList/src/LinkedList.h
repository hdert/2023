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

// void _LinkedList_print_helper(Node *LinkedList);

void LinkedList_append(Head *HEAD, int value);

int LinkedList_pop(Head *HEAD, int index);

// int _LinkedList_pop_helper(Node **LinkedList, int index, int value);

// int main(void);

#endif // LINKEDLIST_H