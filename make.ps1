Remove-item analyser.tab.c
Remove-item analyser.tab.h
Remove-item validator.exe
Remove-item lex.yy.c
.\..\flex_bison\win_bison.exe -d analyser.y
.\..\flex_bison\win_flex.exe lexer.l
g++ lex.yy.c grammar.cpp grammar.h analyser.tab.h analyser.tab.c -o validator
Get-Content config.in | .\validator.exe