CC = zig cc
SHELL = /bin/sh
.SUFFIXES:
.SUFFIXES: .c .o .h

BUILD = .build
EXE = Tests
SRC = src
LIBRARIES = 

$(BUILD)/$(EXE).o: $(SRC)/*.c
	$(CC) $^ -o $@ $(LIBRARIES)
	valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes --verbose --log-file=./.build/valgrind-out.txt ./.build/Tests.o
