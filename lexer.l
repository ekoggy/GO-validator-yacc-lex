%{
#include <stdio.h>
#include <stdlib.h>
#include "parcer.h"
extern int yyscope;
extern int yylineno;
%}
    
underscore                  [_]
digit                       [0-9]
digits                      {digit}+
letter                      [a-zA-Z]
optionalFraction            (\.{digits})?
optionalExponent            ([Ee][+-]?{digits})?
intNumber                   {digits}
floatNumber                 {digits}{optionalFraction}{optionalExponent}
identifier                  [a-zA-Z][a-zA-Z0-9\.]*
types                       (int|bool|float|string|char|identifier)


%%

\n  						                 {++yylineno;}
\/\/(.*)                                     {;}
\/\*([^*]|[\r\n]|(\*+([^*/]|[\r\n])))*\*+\/  {for(int i = 0; i < strlen(yytext); i++)if(yytext[i] == '\n'){ ++yylineno;}}

 /* SPACE REMOVAL */

\t 						                     {;}
[ ] 					                     {;}
\r                                           {;}
\f                                           {;}



 /* RESERVED "KEYWORD"S */
package[ ][a-z_]* 		                     {return T_PACKAGE;}
func					                     {return T_FUNC;}
var						                     {return T_VAR;}
int						                     {return T_INT;}
string					                     {return T_STR;}
float64                                      {return T_FLT64;}                                            
bool                                         {return T_BOOL;}
fallthrough                                  {return T_FALLTHROUGH;}
default                                      {return T_DEFAULT;}
switch                                       {return T_SWITCH;}
case                                         {return T_CASE;}
repeat                                       {return T_REPEAT;}
until                                        {return T_UNTIL;}
import                                       {return T_IMPORT;}
return                                       {return T_RETURN;}
type                                         {return T_TYPE;}
struct                                       {return T_STRUCT;}
if                                           {return T_IF;}
break                                        {return T_BREAK;}
for                                          {return T_FOR;}
else                                         {return T_ELSE;}


 /* "OPERATOR"S */
"+="					                     {return T_SPLUS;}
"-="					                     {return T_SMINUS;}
"*="					                     {return T_SMUL;}
"/="					                     {return T_SDIV;}
"%="					                     {return T_SMOD;}
"&="					                     {return T_SAND;}
"^="					                     {return T_SOR;}
"|="					                     {return T_SOR;}                     
"!="				                         {return T_NOTEQ;}
"=="				                         {return T_COMP;}
"<="				                         {return T_LTE;}
">="				                         {return T_GTE;}
"&&"				                         {return T_AND;}
"||"				                         {return T_OR;}
"<<"					                     {return T_LSHIFT;}
">>"					                     {return T_RSHIFT;}
"+"                                          {return T_PLUS;}
"-"                                          {return T_MINUS;}
"/"                                          {return T_DIV;}
"*"                                          {return T_MUL;}
"%"					                         {return T_MOD;}
"<"					                         {return T_LT;}
">"					                         {return T_GT;}
"="					                         {return T_ASSIGN;}
":="                                         {return T_WALRUS;}
"!"					                         {return T_BNOT;}
"&"					                         {return T_BAND;}
"|"					                         {return T_BOR;}
"^"					                         {return T_BXOR;}


 /* "SEPARATOR"S */

";"					                         {return T_SEMI;}
","			                                 {return T_COMMA;}
":"                                          {return T_COLON;}
"("					                         {return T_PAREN_OPEN;}
")"					                         {return T_PAREN_CLOSE;}
"{"					                         {return T_CURLY_OPEN;}
"}"					                         {return T_CURLY_CLOSE;}
"["					                         {return T_BRACKET_OPEN;}
"]"					                         {return T_BRACKET_CLOSE;}
"."					                         {return T_DOT;}
underscore                                   {return T_UNDER;}



 /* "LITERAL"S */
false                                        {return T_FALSE;}
true                                         {return T_TRUE;}
{intNumber}                                  {return T_INTEGER;}
\"([^"\n])*(\n)([^"])*\"                     {printf("\033[0;31mERROR at line number : %d\n \033[0;0m Invalid String : \033[0;35m%s\033[0;0m\n Strings cannot contain newlines. \n\n", yylineno, yytext);
                                                int found=-1;
                                                int first = -1;
                                                for(int i =0;i<strlen(yytext);++i){
                                                    if(yytext[i]==10){
                                                        found = i;
                                                        if (first==-1)
                                                            first = i;
                                                        ++yylineno;
                                                    }
                                                }
                                                yytext[first]='\0';
                                                return T_STRING;
                                             }
\"[^"]*\"				                     {return T_STRING;}
{floatNumber}                                {return T_FLOAT64;}
map\[{types}\]{types}                        {return T_MAP;}



{identifier}			                     {return T_IDENTIFIER;}


 /* For any other token print error */
.                                            {   
                                                 printf("\033[0;31m");
                                                 printf("ERROR");
                                                 printf("\033[0m");
                                                 printf(" : Unexpected character \033[0;35m%s\033[0m at \033[0;33mline number %d\033[0m, could not classify as any token.\n\n", yytext ,yylineno);
                                             }



%%

int yywrap(){
    return 1;
}
