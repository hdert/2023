#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include "LinkedList.h"

static void LinkedList_print_helper(Node *LinkedList)
{
    printf(", %lf", LinkedList->value);
    if (LinkedList->ptr != NULL)
    {
        LinkedList_print_helper(LinkedList->ptr);
    }
}

void LinkedList_print(Head HEAD)
{
    if (HEAD.ptr == NULL)
    {
        printf("{}\n");
        return;
    }
    printf("{%lf", HEAD.ptr->value);
    if (HEAD.ptr->ptr != NULL)
    {
        LinkedList_print_helper(HEAD.ptr->ptr);
    }
    printf("}\n");
}

static bool LinkedList_append_helper(Node *LinkedList, double value)
{
    if (LinkedList->ptr == NULL)
    {
        LinkedList->ptr = (Node *)malloc(sizeof(Node));
        if (LinkedList->ptr == NULL)
        {
            return false;
        }
        LinkedList->ptr->ptr = NULL;
        LinkedList->ptr->value = value;
        return true;
    }
    return LinkedList_append_helper(LinkedList->ptr, value);
}

bool LinkedList_append(Head *HEAD, double value)
{
    HEAD->length++;
    if (HEAD->ptr == NULL)
    {
        HEAD->ptr = (Node *)malloc(sizeof(Node));
        if (HEAD->ptr == NULL)
        {
            return false;
        }
        HEAD->ptr->ptr = NULL;
        HEAD->ptr->value = value;
        return true;
    }
    return LinkedList_append_helper(HEAD->ptr, value);
}

static bool LinkedList_add_helper(Node **LinkedList, double value, int index)
{
    if (index == 0)
    {
        Node *current_node = *LinkedList;
        *LinkedList = (Node *)malloc(sizeof(Node));
        if (*LinkedList == NULL)
        {
            return false;
        }
        (*LinkedList)->ptr = current_node;
        (*LinkedList)->value = value;
        return true;
    }
    if ((*LinkedList)->ptr == NULL)
    {
        printf("Index out of bounds!\n");
        return false;
    }
    return LinkedList_add_helper(&(*LinkedList)->ptr, value, index - 1);
}

bool LinkedList_add(Head *HEAD, double value, int index)
{
    if (index > HEAD->length)
    {
        printf("Index out of bounds!\n");
        return false;
    }
    if (index == HEAD->length)
    {
        return LinkedList_append(HEAD, value);
    }
    else
    {
        HEAD->length++;
        return LinkedList_add_helper(&(HEAD->ptr), value, index);
    }
}

static bool LinkedList_pop_helper(Node **LinkedList, int index, double *value)
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
    return LinkedList_pop_helper(&((*LinkedList)->ptr), index - 1, value);
}

double LinkedList_pop(Head *HEAD, int index)
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
    double value;
    if (LinkedList_pop_helper(&(HEAD->ptr), index, &value))
    {
        HEAD->length--;
        return value;
    }
    return 0;
}

static void LinkedList_free_helper(Node *LinkedList)
{
    if (LinkedList->ptr != NULL)
    {
        LinkedList_free_helper(LinkedList->ptr);
    }
    free(LinkedList);
}
void LinkedList_free(Head *HEAD)
{
    if (HEAD->ptr != NULL)
    {
        LinkedList_free_helper(HEAD->ptr);
    }
    HEAD->ptr = NULL;
    HEAD->length = 0;
}

static double LinkedList_get_helper(Node *LinkedList, int index)
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
    return LinkedList_get_helper(LinkedList->ptr, index - 1);
}

double LinkedList_get(Head HEAD, int index)
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
    return LinkedList_get_helper(HEAD.ptr, index);
}

static bool LinkedList_find_helper(Node *LinkedList, double key, int *index)
{
    if (LinkedList->value == key) // TODO: This is going to be messy with doubles
    {
        return true;
    }
    if (LinkedList->ptr == NULL)
    {
        return false;
    }
    (*index)++;
    return LinkedList_find_helper(LinkedList->ptr, key, index);
}

bool LinkedList_find(Head HEAD, double key, int *index)
{
    *index = 0;
    if (HEAD.ptr == NULL)
    {
        printf("Linked list empty!\n");
        return false;
    }
    return LinkedList_find_helper(HEAD.ptr, key, index);
}
