typedef struct Node
{
    int value;
    struct Node *ptr;
} Node;

// void _LinkedList_print_helper(Node *LinkedList);

void LinkedList_print(Node *LinkedList);

void LinkedList_append(Node *LinkedList, int value);

// int main(void);