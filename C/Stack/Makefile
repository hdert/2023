SHELL = /bin/sh
.SUFFIXES:
.SUFFIXES: .c .out .h

LinkedListTests: src/Tests.c
	zig cc src/Tests.c src/Stack.c /home/hdert/Documents/repos/2023/C/LinkedList/src/LinkedList.c -o .build/Tests.out
	valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes --verbose --log-file=./.build/valgrind-out.txt ./.build/Tests.out
	