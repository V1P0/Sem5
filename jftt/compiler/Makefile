FLAGS = -std=c++17 --pedantic -Wall -Wextra

all: compiler clean

compiler: parser.o lexer.o utils.o code_gen.o
	g++ $(FLAGS) -o compiler parser.o lexer.o utils.o code_gen.o

lexer.o: lexer.c	
	g++ $(FLAGS) -c lexer.c

parser.o: parser.tab.c
	g++ $(FLAGS) -c parser.tab.c -o parser.o

utils.o: utils.cpp
	g++ $(FLAGS) -c utils.cpp

code_gen.o: code_gen.cpp
	g++ $(FLAGS) -c code_gen.cpp

lexer.c: lexer.l
	flex -o lexer.c lexer.l

parser.tab.c: parser.y
	bison -d parser.y

clean:
	rm -f *.o *~ *.c *.tab.c *.tab.h