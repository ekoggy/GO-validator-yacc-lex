.PHONY : build clean all

build: 
	bison -o parcer.c -d analyser.y
	lex -o lexer.c lexer.l 
	gcc lexer.c parcer.c parcer.h -o validator

clean:
	rm -f -d lex.yy.c
	rm -f -d validator
	rm -f -d parcer.*

run:
	./validator <config.in out

all: clean build run
