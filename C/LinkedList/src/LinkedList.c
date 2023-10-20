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

static void _LinkedList_add_helper(Node **LinkedList, int value, int index)
{
    if (index == 0)
    {
        Node *current_node = *LinkedList;
        *LinkedList = (Node *)malloc(sizeof(Node));
        (*LinkedList)->ptr = current_node;
        (*LinkedList)->value = value;
        return;
    }
    if ((*LinkedList)->ptr == NULL)
    {
        printf("Index out of bounds!\n");
        return;
    }
    _LinkedList_add_helper(&(*LinkedList)->ptr, value, index - 1);
}

void LinkedList_add(Head *HEAD, int value, int index)
{
    if (index > HEAD->length)
    {
        printf("Index out of bounds!\n");
        return;
    }
    if (index == HEAD->length)
    {
        LinkedList_append(HEAD, value);
        return;
    }
    else
    {
        _LinkedList_add_helper(&(HEAD->ptr), value, index);
    }
    HEAD->length++;
}

static bool _LinkedList_pop_helper(Node **LinkedList, int index, int *value)
{
    if (index == 0)
    {
        Node *current_node = *LinkedList;
        *value = (*LinkedList)->value;
        *LinkedList = (*LinkedList)->ptr;
        free(current_node);
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
    if (HEAD->ptr == NULL)
    {
        printf("Linked list already empty!\n");
        return 0;
    }
    if (index > HEAD->length - 1)
    {
        printf("Index out of bounds!\n");
        return 0;
    }
    int value;
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
    HEAD->ptr = NULL;
    HEAD->length = 0;
}

static int _LinkedList_get_helper(Node *LinkedList, int index)
{
    if (!index)
    {
        return LinkedList->value;
    }
    if (LinkedList->ptr == NULL)
    {
        printf("Index out of bounds!\n");
        return 0;
    }
    return _LinkedList_get_helper(LinkedList->ptr, index - 1);
}

int LinkedList_get(Head HEAD, int index)
{
    if (HEAD.ptr == NULL)
    {
        printf("Linked list empty!\n");
        return 0;
    }
    if (index > HEAD.length - 1)
    {
        printf("Index out of bounds!\n");
        return 0;
    }
    return _LinkedList_get_helper(HEAD.ptr, index);
}

static bool _LinkedList_find_helper(Node *LinkedList, int key, int *index)
{
    if (LinkedList->value == key)
    {
        return true;
    }
    if (LinkedList->ptr == NULL)
    {
        return false;
    }
    (*index)++;
    return _LinkedList_find_helper(LinkedList->ptr, key, index);
}

bool LinkedList_find(Head HEAD, int key, int *index)
{
    *index = 0;
    if (HEAD.ptr == NULL)
    {
        printf("Linked list empty!\n");
        return false;
    }
    return _LinkedList_find_helper(HEAD.ptr, key, index);
}
