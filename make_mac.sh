	bison --verbose --debug -o parcer.c -d analyser.y
	lex -o lexer.c lexer.l 
	gcc lexer.c parcer.c -o validator
    ./validator<config.in