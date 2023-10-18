#include <stdio.h>
#include <stdlib.h>

struct Node
{
    int value;
    struct Node *ptr;
};

void _LinkedList_print_helper(struct Node *LinkedList)
{
    printf(", %d", LinkedList->value);
    if (LinkedList->ptr != NULL)
    {
        _LinkedList_print_helper(LinkedList->ptr);
    }
}

void LinkedList_print(struct Node *LinkedList)
{
    printf("{%d", LinkedList->value);
    if (LinkedList->ptr != NULL)
    {
        _LinkedList_print_helper(LinkedList->ptr);
    }
    printf("}\n");
}

void LinkedList_append(struct Node *LinkedList, int value)
{
    if (LinkedList->ptr == NULL)
    {
        LinkedList->ptr = (struct Node *)malloc(sizeof(struct Node));
        LinkedList->ptr->value = value;
        return;
    }
    LinkedList_append(LinkedList->ptr, value);
}

int main(void)
{
    struct Node *HEAD, LinkedList = {11, NULL};
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
    return 0;
}