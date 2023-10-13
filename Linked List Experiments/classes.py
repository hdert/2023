"""Implement a Linked List, Doubly Linked List, and Deque."""

import doctest


class LinkedList():
    """Implement a Linked List.

    >>> a = LinkedList(1, 2, 3)
    >>> a.append(0)
    >>> a.append(1)
    >>> print(a.__repr__())
    LinkedList([1, 2, 3, 0, 1])
    >>> b = LinkedList()
    >>> b.append(10)
    >>> print(b.__repr__())
    LinkedList([10])
    >>> print((a + b).__repr__())
    LinkedList([1, 2, 3, 0, 1, 10])
    """

    def __init__(self, *data, start=True):
        """Initialize the LinkedList object."""
        if len(data) == 0:
            self._data = None
            self._next = None
            return
        if start:
            self._data = None
            self._next = LinkedList(*data, start=False)
            return
        self._data = data[0]
        if len(data) == 1:
            self._next = None
            return
        self._next = LinkedList(*data[1:], start=False)

    def __len__(self):
        """Return the length of the Linked List."""
        if self._next is None:
            return 1
        return self._next.__len__() + 1

    def __contains__(self, key):
        """Return if the list contains the key."""
        if self._data == key:
            return True
        if self._next is None:
            return False
        return self._next.__contains__(key)

    def append(self, data):
        """Append object to the end of the list."""
        if self._next is None:
            self._next = LinkedList(data, start=False)
            return
        self._next.append(data)

    def __add__(self, linked_list):
        """Return two Linked Lists added to each other."""
        return LinkedList(*(list(self) + list(linked_list)))

    def __getitem__(self, items, index=-1):
        """Implement x[y]."""
        if isinstance(items, slice):
            raise TypeError("LinkedList doesn't accept slice objects")
        if not isinstance(items, int):
            raise TypeError("LinkedList only accepts integers")
        if items < 0:
            raise ValueError("LinkedList only accepts positive indexes")
        if items == index:
            return self._data
        if self._next is None:
            raise IndexError("LinkedList out of range")
        return self._next.__getitem__(items, index + 1)

    def __repr__(self):
        """Return a string representation of itself."""
        return f"LinkedList({list(self)})"

    def __str__(self):
        """Return itself in printable format."""
        return f"\n{self._data}: {self._next}"


if __name__ == "__main__":
    # a = LinkedList(0, 1, 2)
    # a.append(0)
    # print(a)
    # print(list(a))
    doctest.testmod()
