#include <stdio.h>
#include <stdlib.h>
#include "LinkedList.h"

void _LinkedList_print_helper(Node *LinkedList)
{
    printf(", %d", LinkedList->value);
    if (LinkedList->ptr != NULL)
    {
        _LinkedList_print_helper(LinkedList->ptr);
    }
}

void LinkedList_print(Node *LinkedList)
{
    printf("{%d", LinkedList->value);
    if (LinkedList->ptr != NULL)
    {
        _LinkedList_print_helper(LinkedList->ptr);
    }
    printf("}\n");
}

void LinkedList_append(Node *LinkedList, int value)
{
    if (LinkedList->ptr == NULL)
    {
        LinkedList->ptr = (Node *)malloc(sizeof(Node));
        LinkedList->ptr->value = value;
        return;
    }
    LinkedList_append(LinkedList->ptr, value);
}

int main(void)
{
    Node *HEAD, LinkedList = {11, NULL};
    HEAD = &LinkedList;
    LinkedList_print(HEAD);
    LinkedList_append(HEAD, 12);
    LinkedList_print(HEAD);
    int nums[] = {1, 2, 3, 4, 5, 6, 7, 8, 12, 3, 123, 532, 643, 1};
    for (int i = 0; i < sizeof nums / sizeof(int); i++)
    {
        LinkedList_append(HEAD, nums[i]);
    }
    LinkedList_print(HEAD);
    Node *Empty_HEAD, Empty_LinkedList;
    Empty_HEAD = &Empty_LinkedList;
    LinkedList_print(Empty_HEAD);
    return 0;
}