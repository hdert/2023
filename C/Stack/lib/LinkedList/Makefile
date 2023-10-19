CC = zig cc
SHELL = /bin/sh
.SUFFIXES:
.SUFFIXES: .c .o .h

BUILD = .build
EXE = Tests
SRC = src
LIBRARIES = 
LIB = lib

$(BUILD)/$(EXE).o: $(SRC)/*.c
	$(CC) $^ -o $@ -I $(LIB) $(LIBRARIES) -g
	valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes --verbose --log-file=$(BUILD)/valgrind-out.txt $(BUILD)/$(EXE).o
