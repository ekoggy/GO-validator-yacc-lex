.PHONY : build clean all

TARGET=validator

build: 
	bison --verbose --debug -o parcer.c -d analyser.y
	lex -o lexer.c lexer.l 
	gcc lexer.c parcer.c parcer.h -o validator

clean:
	rm -f -d lex.yy.c
	rm -f -d validator
	rm -f -d parcer.*

test:
	for test in testCases/* ; do \
			./$(TARGET) $$test ; \
		done

all: clean build
