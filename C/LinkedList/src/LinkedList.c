#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include "LinkedList.h"

static void _LinkedList_print_helper(Node *LinkedList)
{
    printf(", %d", LinkedList->value);
    if (LinkedList->ptr != NULL)
    {
        _LinkedList_print_helper(LinkedList->ptr);
    }
}

void LinkedList_print(Head HEAD)
{
    if (HEAD.ptr == NULL)
    {
        printf("{}\n");
        return;
    }
    printf("{%d", HEAD.ptr->value);
    if (HEAD.ptr->ptr != NULL)
    {
        _LinkedList_print_helper(HEAD.ptr->ptr);
    }
    printf("}\n");
}

static void _LinkedList_append_helper(Node *LinkedList, int value)
{
    if (LinkedList->ptr == NULL)
    {
        LinkedList->ptr = malloc(sizeof(Node));
        LinkedList->ptr->ptr = NULL;
        LinkedList->ptr->value = value;
        return;
    }
    _LinkedList_append_helper(LinkedList->ptr, value);
}

void LinkedList_append(Head *HEAD, int value)
{
    HEAD->length++;
    if (HEAD->ptr == NULL)
    {
        HEAD->ptr = (Node *)malloc(sizeof(Node));
        HEAD->ptr->ptr = NULL;
        HEAD->ptr->value = value;
        return;
    }
    _LinkedList_append_helper(HEAD->ptr, value);
}

static bool _LinkedList_pop_helper(Node **LinkedList, int index, int *value)
{
    if (!index)
    {
        Node *temp = *LinkedList;
        *value = (*LinkedList)->value;
        *LinkedList = (*LinkedList)->ptr;
        free(temp);
        return true;
    }
    if (!(*LinkedList)->ptr)
    {
        printf("Index out of bounds!\n");
        return false;
    }
    return _LinkedList_pop_helper(&((*LinkedList)->ptr), index - 1, value);
}

int LinkedList_pop(Head *HEAD, int index)
{
    int value;
    if (HEAD->ptr == NULL)
    {
        printf("Linked list already empty!");
        return 0;
    }
    if (_LinkedList_pop_helper(&(HEAD->ptr), index, &value))
    {
        HEAD->length--;
        return value;
    }
    return 0;
}

static void _LinkedList_free_helper(Node *LinkedList)
{
    if (LinkedList->ptr != NULL)
    {
        _LinkedList_free_helper(LinkedList->ptr);
    }
    free(LinkedList);
}
void LinkedList_free(Head *HEAD)
{
    if (HEAD->ptr != NULL)
    {
        _LinkedList_free_helper(HEAD->ptr);
    }
    HEAD = NULL;
}

int main(void)
{
    // Node LinkedList = {11, NULL}; // DO NOT DO THIS, you cannot free it later!
    Head HEAD = {NULL, 0};
    LinkedList_append(&HEAD, 11);
    LinkedList_print(HEAD);
    printf("Length: %d\n", HEAD.length);
    LinkedList_append(&HEAD, 12);
    LinkedList_print(HEAD);
    printf("Length: %d\n", HEAD.length);
    int nums[] = {1, 2, 3, 4, 5, 6, 7, 8, 12, 3, 123, 532, 643, 13};
    for (int i = 0; i < sizeof nums / sizeof(int); i++)
    {
        LinkedList_append(&HEAD, nums[i]);
    }
    LinkedList_print(HEAD);
    printf("Length: %d\n", HEAD.length);
    printf("%d\n", LinkedList_pop(&HEAD, 0));
    LinkedList_print(HEAD);
    printf("Length: %d\n", HEAD.length);
    printf("%d\n", LinkedList_pop(&HEAD, 1));
    LinkedList_print(HEAD);
    printf("Length: %d\n", HEAD.length);
    printf("%d\n", LinkedList_pop(&HEAD, HEAD.length - 1));
    LinkedList_print(HEAD);
    printf("Length: %d\n", HEAD.length);
    printf("Empty_HEAD:\n");
    Head Empty_HEAD = {NULL, 0};
    // fprintf(stderr, "%p", Empty_HEAD.ptr);
    LinkedList_print(Empty_HEAD);
    printf("Length: %d\n", Empty_HEAD.length);
    LinkedList_append(&Empty_HEAD, 121);
    LinkedList_print(Empty_HEAD);
    printf("Length: %d\n", Empty_HEAD.length);
    printf("%d\n", LinkedList_pop(&Empty_HEAD, 0));
    LinkedList_print(Empty_HEAD);
    printf("Length: %d\n", Empty_HEAD.length);
    // fprintf(stderr, "%p\n", Empty_HEAD.ptr);
    printf("Memory leak test");
    Head MemLeak_HEAD = {NULL, 0};
    for (int i = 0; i < 100; i++)
    {
        LinkedList_append(&MemLeak_HEAD, 1);
        LinkedList_pop(&MemLeak_HEAD, 0);
    }
    LinkedList_free(&HEAD);
    LinkedList_free(&Empty_HEAD);
    LinkedList_free(&MemLeak_HEAD);
    return 0;
}