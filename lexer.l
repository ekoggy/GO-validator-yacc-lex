%{

//Это когда будут библиотеки и нужна будет переносимость 
/*#ifdef __unix__
// __unix__ is usually defined by compilers targeting Unix systems
#include "y.tab.h"
#elif defined _WIN32
// _Win32 is usually defined by compilers targeting 32 or 64 bit Windows systems
#include "parser.tab.h"
#endif
//временная библа с дефайнами вместо неё будут либы выше
#include "temp_lib.h"
*/

int yylex();
%option yylineno
%option  noyywrap
%}

LETTER                  [a-zA-Z]
DIGIT                   [0-9]
OCT                     [0-7]
HEX                     [0-9|a-f|A-F]

UNICODE_CHAR            [^\n]
OCT_BYTE                ["\\"]OCT{3}
HEX_BYTE                ["\\"]["x"]HEX{2}
LITTLE_U                ["\\"]["u"]HEX{4}
BIG_U                   ["\\"]["U"]HEX{8}
ESCAPED_CHAR            ["\\"][ "a" | "b" | "f" | "n" | "r" | "t" | "v" | "\\" | "'" | "\""]
BYTE                    OCT_BYTE | HEX_BYTE
UNICODE_VALUE           UNICODE_CHAR | LITTLE_U | BIG_U | ESCAPED_CHAR
RUNE                    \'( UNICODE_VALUE|BYTE)\'


NEW_LINE                [\n]
VAR_TYPE                "bool"|"byte"|"error"|"float32"|"float64"|"int"|"int8"|
                        "int16"|"int32"|"int64"|"rune"|"string"|"uint"|"uint8"|
                        "uint16"|"uint32"|"uint64"|"uintptr"|complex64|complex128
BOOL_CONST              "true"|"false"
NIL_VAL                 "nil"

MATH_SIGN               "+" | "-" | "/" | "%"
ASTERISK                "*"
UNO_OPERATION           "--" | "++"
MATH_EQ_SIGN            "+=" | "-=" | "/=" | "%=" | "*="
COMPARISON_SIGN         ">" | ">=" | "==" | "!=" | "<=" | "<" | "&&" | "||"
LOGICAL_SINGS           "!" | "&" | "|" | "^" | ">>" | "<<" | "&^"
LOGICAL_EQ_SIGN         "&=" | "|=" | "^=" | "<<=" | ">>=" | "&^="
EQUAL                   "="

CURLY_BRACKET_LEFT      "{"
CURLY_BRACKET_RIGHT     "}"
REGULAR_BRACKET_LEFT    "("
REGULAR_BRACKET_RIGHT   ")"
SQUARE_BRACKET_LEFT     "["
SQUARE_BRACKET_RIGHT    "]"

%Start out_com in_single in_multi
%%
                        BEGIN out_com;
               
<out_com>"/*"           BEGIN in_multi;
<in_multi>.|\n          ;
<in_multi>"*/"          BEGIN in_single;

<out_com>"//"           BEGIN in_single;
<in_single>.            ;
<in_single>\n           BEGIN out_com;

<out_com>"~"                            return TILDE
<out_com>"->"                           return ARROW;
<out_com>":="                           return DEFINE;
<out_com>"..."                          return ELLIPSIS;
<out_com>","                            return COMMA;
<out_com>";"                            return SEMICOLON;
<out_com>":"                            return COLON;
<out_com>"."                            return PERIOD;

<out_com>"package"                      return PACKAGE;
<out_com>"import"                       return IMPORT;
<out_com>"func"                         return FUNC;
<out_com>"break"                        return BREAK;
<out_com>"case"                         return CASE;
<out_com>"const"                        return CONST;
<out_com>"continue"                     return CONTINUE;
<out_com>"default"                      return DEFAULT;
<out_com>"else"                         return ELSE;
<out_com>"for"                          return FOR;
<out_com>"go"                           return GO;
<out_com>"if"                           return IF;
<out_com>"range"                        return RANGE;
<out_com>"return"                       return RETURN;
<out_com>"struct"                       return STRUCT;
<out_com>"switch"                       return SWITCH;
<out_com>"type"                         return TYPE;
<out_com>"var"                          return VAR;

<out_com>{VAR_TYPE}                     return VAR_TYPE;
<out_com>{BOOL_CONST}                   return BOOL_CONST;
<out_com>{NIL_VAL}                      return NIL_VAL;

<out_com>{MATH_SIGN}                    return MATH_SIGN;
<out_com>{MATH_EQ_SIGN}                 return MATH_EQ_SIGN;
<out_com>{COMPARISON_SIGN}              return COMPARISON_SIGN;

<out_com>{LOGICAL_SINGS}                return LOGICAL_SINGS;
<out_com>{LOGICAL_EQ_SIGN}              return LOGICAL_EQ_SIGN;
<out_com>{EQUAL}                        return EQUAL;

<out_com>{CURLY_BRACKET_LEFT}           return CURLY_BRACKET_LEFT;
<out_com>{CURLY_BRACKET_RIGHT}          return CURLY_BRACKET_RIGHT;
<out_com>{REGULAR_BRACKET_LEFT}         return REGULAR_BRACKET_LEFT;
<out_com>{REGULAR_BRACKET_RIGHT}        return REGULAR_BRACKET_RIGHT;
<out_com>{SQUARE_BRACKET_LEFT}          return SQUARE_BRACKET_LEFT;
<out_com>{SQUARE_BRACKET_RIGHT}         return SQUARE_BRACKET_RIGHT;

<out_com>{LETTER}({LETTER}|{DIGIT}|_)*                               return IDENTIFIER;
<out_com>[+-]?{DIGIT}+                                               return INTEGER;
<out_com>[+-]?{DIGIT}+(\.{DIGIT}+)?([Ee][+-]?{DIGIT}+)?              return FLOAT;

<out_com>\"([^\\\n\"]|(\\.))*\"|\`(.)*\`                             return STRING;
<out_com>{LETTER}({LETTER}|{DIGIT}|_)*\[{DIGIT}*\]                   return ARR;
<out_com>"\n"                gLineNum++;
<out_com>"\t"                ;
<out_com>" "                 ;
<out_com>.                   printf("ERROR : unexpected character in line %d\n",yylineno);
<out_com><<EOF>>             {gLineNum++; return END_OF_FILE;}
%%
