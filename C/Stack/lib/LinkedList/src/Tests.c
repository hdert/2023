#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include "LinkedList.h"

int main(void)
{
    // Node LinkedList = {11, NULL}; // DO NOT DO THIS, you cannot free it later!
    Head HEAD = {NULL, 0};
    LinkedList_append(&HEAD, 11);
    LinkedList_print(HEAD);              // {11}
    printf("Length: %d\n", HEAD.length); // Length: 1
    LinkedList_append(&HEAD, 12);
    LinkedList_print(HEAD);              // {11, 12}
    printf("Length: %d\n", HEAD.length); // Length: 2
    int nums[] = {1, 2, 3, 4, 5, 6, 7, 8, 12, 3, 123, 532, 643, 13};
    for (int i = 0; i < sizeof nums / sizeof(int); i++)
    {
        LinkedList_append(&HEAD, nums[i]);
    }
    LinkedList_print(HEAD);                                     // {11, 12, 1, 2, 3, 4, 5, 6, 7, 8, 12, 3, 123, 532, 643, 13}
    printf("Length: %d\n", HEAD.length);                        // Length: 16
    printf("%d\n", LinkedList_pop(&HEAD, 0));                   // 11
    LinkedList_print(HEAD);                                     // {12, 1, 2, 3, 4, 5, 6, 7, 8, 12, 3, 123, 532, 643, 13}
    printf("Length: %d\n", HEAD.length);                        // Length: 15
    printf("%d\n", LinkedList_pop(&HEAD, 1));                   // 1
    LinkedList_print(HEAD);                                     // {12, 2, 3, 4, 5, 6, 7, 8, 12, 3, 123, 532, 643, 13}
    printf("Length: %d\n", HEAD.length);                        // Length: 14
    printf("%d\n", LinkedList_pop(&HEAD, HEAD.length - 1));     // 13
    LinkedList_print(HEAD);                                     // {12, 2, 3, 4, 5, 6, 7, 8, 12, 3, 123, 532, 643}
    printf("Length: %d\n", HEAD.length);                        // Length: 13
    printf("Get: %d\n", LinkedList_get(HEAD, 0));               // Get: 12
    printf("Get: %d\n", LinkedList_get(HEAD, 1));               // Get: 2
    printf("Get: %d\n", LinkedList_get(HEAD, HEAD.length - 1)); // Get: 643
    printf("Get: %d\n", LinkedList_get(HEAD, HEAD.length));     // Index out of bounds!\nGet: 0
    int index;
    bool result = LinkedList_find(HEAD, 12, &index);
    printf(result // Found: 0
               ? "Found: %d\n"
               : "Not Found: %d\n",
           index);
    result = LinkedList_find(HEAD, 643, &index);
    printf(result // Found: 12
               ? "Found: %d\n"
               : "Not Found: %d\n",
           index);
    result = LinkedList_find(HEAD, 0, &index);
    printf(result // Not Found: 12
               ? "Found: %d\n"
               : "Not Found: %d\n",
           index);

    // ****************** Empty_HEAD ******************

    printf("Empty_HEAD:\n"); // Empty_HEAD:
    Head Empty_HEAD = {NULL, 0};
    // fprintf(stderr, "%p", Empty_HEAD.ptr);
    LinkedList_print(Empty_HEAD);                       // {}
    printf("Length: %d\n", Empty_HEAD.length);          // Length: 0
    printf("Get: %d\n", LinkedList_get(Empty_HEAD, 1)); // Linked list empty!\nGet: 0
    printf("Get: %d\n", LinkedList_get(Empty_HEAD, 0)); // Linked list empty!\nGet: 0
    LinkedList_append(&Empty_HEAD, 121);
    LinkedList_print(Empty_HEAD);                   // {121}
    printf("Length: %d\n", Empty_HEAD.length);      // Length: 1
    printf("%d\n", LinkedList_pop(&Empty_HEAD, 0)); // 121
    LinkedList_print(Empty_HEAD);                   // {}
    printf("Length: %d\n", Empty_HEAD.length);      // Length: 0
    LinkedList_append(&Empty_HEAD, 1);
    LinkedList_append(&Empty_HEAD, 2);
    LinkedList_print(Empty_HEAD);                                       // {1, 2}
    printf("Length: %d\n", Empty_HEAD.length);                          // Length: 2
    printf("%d\n", LinkedList_pop(&Empty_HEAD, Empty_HEAD.length));     // Index out of bounds!\n0
    printf("%d\n", LinkedList_pop(&Empty_HEAD, Empty_HEAD.length - 1)); // 2
    LinkedList_print(Empty_HEAD);                                       // {1}
    printf("Length: %d\n", Empty_HEAD.length);                          // Length: 1
    printf("Get: %d\n", LinkedList_get(Empty_HEAD, 1));                 // Index out of bounds!\nGet: 0
    printf("%d\n", LinkedList_pop(&Empty_HEAD, Empty_HEAD.length - 1)); // 1
    LinkedList_print(Empty_HEAD);                                       // {}
    printf("Length: %d\n", Empty_HEAD.length);                          // Length: 0
    printf("%d\n", LinkedList_pop(&Empty_HEAD, Empty_HEAD.length - 1)); // Linked list empty!\n0
    result = LinkedList_find(Empty_HEAD, 0, &index);
    printf(result // Linked list empty!\nNot Found: 0
               ? "Found: %d\n"
               : "Not Found: %d\n",
           index);
    LinkedList_add(&Empty_HEAD, 1, 0);
    LinkedList_add(&Empty_HEAD, 2, 0);
    LinkedList_print(Empty_HEAD); // {2, 1}
    LinkedList_add(&Empty_HEAD, 3, Empty_HEAD.length);
    LinkedList_print(Empty_HEAD); // {2, 1, 3}
    LinkedList_add(&Empty_HEAD, 4, 1);
    LinkedList_print(Empty_HEAD); // {2, 4, 1, 3}
    LinkedList_pop(&Empty_HEAD, 0);
    LinkedList_print(Empty_HEAD); // {4, 1, 3}
    LinkedList_pop(&Empty_HEAD, 0);
    LinkedList_pop(&Empty_HEAD, 0);
    LinkedList_pop(&Empty_HEAD, 0);
    LinkedList_add(&Empty_HEAD, 5, Empty_HEAD.length);
    LinkedList_print(Empty_HEAD); // {5}
    // fprintf(stderr, "%p\n", Empty_HEAD.ptr);

    // ****************** MemLeak_HEAD ******************

    printf("Memory leak test\n"); // Memory leak test
    Head MemLeak_HEAD = {NULL, 0};
    for (int i = 0; i < 100; i++)
    {
        LinkedList_append(&MemLeak_HEAD, 1);
        LinkedList_pop(&MemLeak_HEAD, 0);
    }
    for (int i = 0; i < 100; i++)
    {
        LinkedList_append(&MemLeak_HEAD, 1);
    }
    LinkedList_free(&HEAD);
    LinkedList_free(&Empty_HEAD);
    LinkedList_free(&MemLeak_HEAD);
    printf("%p, %d\n", HEAD.ptr, HEAD.length);
    LinkedList_print(HEAD);
    return 0;
}