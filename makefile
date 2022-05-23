.PHONY : build clean all

build: 
	bison -d analyser.y
	lex lexer.l
	g++ lex.yy.c y.tab.c grammar.cpp y.tab.h grammar.h -o validator
	./validator <config.in

clean:
	rm -f -d y.tab.*
	rm -f -d lex.yy.c
	rm -f -d validator

all: clean build