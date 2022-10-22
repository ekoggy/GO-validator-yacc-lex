%{

    #include<stdio.h>
    #include<stdlib.h>
    #include<string.h>

    extern void yyerror(char* s); 
    extern int yylex();
    extern FILE *yyin;
    extern FILE *yyout;
    extern int yylineno;
    //extern YYLTYPE yylloc;
    extern char* yytext;
    extern int functionid;
    int yyscope=0;
    int flag=0;
    int valid=1;
    int linecounter = 0;
%}
%locations
%union { 
    char *str;
    }
%start program

%token T_PACKAGE T_MAIN T_FUNC T_PRINT T_VAR T_TYPE T_RETURN T_IF T_BREAK T_FOR T_ELSE T_UNDER T_DEFER T_CONTINUE
%token T_FALLTHROUGH T_DEFAULT T_SWITCH T_CASE T_REPEAT T_UNTIL T_IMPORT T_FMT T_STRUCT T_ENTER T_RANGE
%token T_COMMA T_COLON T_PAREN_OPEN T_PAREN_CLOSE T_CURLY_OPEN T_CURLY_CLOSE T_BRACKET_OPEN T_BRACKET_CLOSE T_DOT T_END_OF_STROKE
%token T_SPLUS T_SMINUS T_SMUL T_SDIV T_SMOD T_SAND T_SOR  T_LSHIFT T_RSHIFT T_PLUS T_MINUS T_DIV T_MUL T_MOD T_WALRUS  T_BAND T_BOR T_BXOR 
%token T_ARROW T_MAKE T_CHAN T_GO T_SELECT T_CLOSE

%token <str> T_FALSE T_TRUE
%token <str> T_INTEGER
%token <str> T_STRING 
%token <str> T_MAP
%token <str> T_ARR
%token <str> T_CTYPE
%token T_ASSIGN T_SEMI
%token <str> T_FLOAT64
%token <str> T_IDENTIFIER
%token <str> T_NOTEQ T_COMP T_LTE T_GTE T_AND T_OR T_BNOT T_LT T_GT
%token <str> T_INT T_STR T_BOOL T_FLT64

%%
//Start program
program                         : T_PACKAGE import external
                                |
                                ;


//All external elements (structs, functions, vars)
external                        : struct external
                                | var external
                                | func external
                                |
                                ;



/********************GENERAL RULES********************/
semi                            : T_SEMI
                                | /* EPSILON */
                                ;

type                            : pointerType
                                | T_BRACKET_OPEN T_BRACKET_CLOSE pointerType
                                | T_BRACKET_OPEN T_INTEGER T_BRACKET_CLOSE pointerType
                                ;

pointerType                     : T_MUL commonType
                                | commonType
                                ;

commonType                      : T_INT    
                                | T_STR    
                                | T_FLT64
                                | T_BOOL
                                | T_MAP 
                                | id
                                ;

id                              : T_IDENTIFIER
                                | T_BAND T_IDENTIFIER
                                ;

value          	                : number
                                | T_STRING
                                | bool
                                ;
                                
number                          : T_INTEGER
                                | T_FLOAT64
                                ;

bool                            : T_TRUE
                                | T_FALSE
                                ;



/********************IMPORTS********************/
import							: T_IMPORT T_PAREN_OPEN importContent T_PAREN_CLOSE semi
								| T_IMPORT T_STRING import semi
                                |
								;
								
importContent					: T_STRING {if(linecounter == yylineno) yyerror("syntax"); linecounter = yylineno;} importComma 
								;
								
importComma						: importContent             
                                | {linecounter = 0;} T_SEMI importContent
								| {linecounter = 0;}
								;



/**********************VARS**********************/
var							    : T_VAR T_PAREN_OPEN varContent T_PAREN_CLOSE semi 
							    | T_VAR T_IDENTIFIER varExpression semi 
                            
								;
								
varContent					    : varIdentifier{if(linecounter == yylineno) yyerror("syntax"); linecounter = yylineno;} varExpression varComma 
								;

varIdentifier                   : T_IDENTIFIER
                                | T_IDENTIFIER T_COMMA varIdentifier
                                | T_UNDER
                                | T_UNDER T_COMMA varIdentifier

varComma						: varContent             
                                | {linecounter = 0;} T_SEMI varContent
								| {linecounter = 0;}
								;

varExpression                   : type T_ASSIGN value
                                | T_ASSIGN value
                                | type
                                | T_BRACKET_OPEN extArraylength T_BRACKET_CLOSE type extArrDefinition semi
                                ;
 
extArrDefinition                : T_CURLY_OPEN extArrayvalues T_CURLY_CLOSE
                                |
                                ;
 
extArraylength                  : number
                                ;

extArrayvalues                  : value
                                | arrayvalues T_COMMA value
                                | 
                                ;



/**********************STRUCTS**********************/

struct							: T_TYPE T_IDENTIFIER T_STRUCT T_CURLY_OPEN structContent T_CURLY_CLOSE semi
								;
								
structContent					: structIdentifier {if(linecounter == yylineno) yyerror("syntax"); linecounter = yylineno;} type structAdd structComma
								;

structAdd                       : T_STRING  
                                |
                                ;          

structIdentifier                : T_IDENTIFIER
                                | T_IDENTIFIER T_COMMA structIdentifier

structComma						: structContent
								| {linecounter = 0;} T_SEMI structContent
								| {linecounter = 0;}
								;



/**********************FUNCTIONS**********************/
//definition
shortFunc                       :T_FUNC{linecounter = yylineno;} parameters functext

func                            : T_FUNC{linecounter = yylineno;} receiver funcname parameters returnvalue functext
                                ;

funcname                        : T_IDENTIFIER
                                ;

//function receiver
receiver                        : T_PAREN_OPEN T_IDENTIFIER type T_PAREN_CLOSE
                                |
                                ;


//input parameters
parameters                      : T_PAREN_OPEN parameterlist T_PAREN_CLOSE
                                ;

parameterlist                   : parameter
                                |
                                ;

parameter                       : parameterIdentifier type parameterComma
                                ;

parameterComma					: parameter             
                                | T_COMMA parameter
								|
								;

parameterIdentifier             : T_IDENTIFIER
                                | T_IDENTIFIER T_COMMA parameterIdentifier


//return value
returnvalue                      : type
                                 | T_PAREN_OPEN multireturn T_PAREN_CLOSE
                                 |
                                 ;

multireturn                      : type returncomma
                                 ;

returncomma                      : T_COMMA returnvalue
                                 |
                                 ;


//function text
functext                        : T_CURLY_OPEN {{if(linecounter != yylineno) yyerror("syntax"); linecounter = yylineno;}} statements T_CURLY_CLOSE
                                ;

statements                      : statement statements
                                | /*EPSILON */
                                ;

statement                       : return
                                | if
                                | arrays
                                | functions
                                | variables
                                | switch
                                | variableAssignment
                                | arrayAssignment
                                | cicles
                                | defer
                                | T_BREAK
                                | repeat
                                | T_CONTINUE
                                ;



/**********************IF-ELSE**********************/
if                              : T_IF ifHead ifBody else
                                ;

ifHead                          : variableAssignment expressions
                                | expressions
                                ;

ifBody                          : T_CURLY_OPEN statements T_CURLY_CLOSE
                                ;

else                            : T_ELSE elseEnd
                                |
                                ;

elseEnd                         : if
                                | ifBody
                                ;



/**********************REPEAT**********************/
repeat                          : T_REPEAT T_CURLY_OPEN statements T_CURLY_CLOSE T_UNTIL repCondition
                                ;

repCondition                    : T_PAREN_OPEN expressions T_PAREN_CLOSE
                                | expressions
                                ;



/**********************DEFER**********************/
defer                           : T_DEFER functions
                                ;



/**********************RETURN**********************/
return                          : T_RETURN returnStatement semi
                                ;

returnStatement                 : expressions funcreturncomma
                                ;

funcreturncomma                 : T_COMMA returnStatement 
                                |
                                ;



/**********************CALLING FUNCTIONS**********************/
functions                       : T_IDENTIFIER argslist funcDot semi
                                ;

funcDot                         : T_DOT functions
                                |
                                ;

argslist                        : T_PAREN_OPEN args T_PAREN_CLOSE
                                | T_PAREN_OPEN  T_PAREN_CLOSE
                                ;

args                            : arg argsEnd
                                ;

argsEnd                         : T_COMMA args
                                |
                                ;

arg                             : expressions
                                | shortFunc
                                | structures
                                ;



/**********************VARIABLE DECLARATION**********************/
variables                       : T_VAR T_PAREN_OPEN funcVarContent T_PAREN_CLOSE semi
                                | T_VAR funcVarIdentifier type varEnd semi
                                | T_VAR T_IDENTIFIER T_ASSIGN expressions semi                                
                                | T_VAR T_IDENTIFIER T_ASSIGN structures semi
                                ;

varEnd                          : T_ASSIGN expressions
                                |
                                ;

funcVarContent					: funcVarIdentifier{if(linecounter == yylineno) yyerror("syntax"); linecounter = yylineno;} funcVarExpression funcVarComma 
								;

funcVarIdentifier               : T_IDENTIFIER
                                | T_IDENTIFIER T_COMMA varIdentifier
                                ;

funcVarComma					: funcVarContent             
                                | {linecounter = 0;} T_SEMI funcVarContent
								| {linecounter = 0;}
								;

funcVarExpression               : type T_ASSIGN value
                                | T_ASSIGN value
                                | type
                                ;



/**********************SWITCH**********************/
switch                          : T_SWITCH switchCondition semi T_CURLY_OPEN switchCaseStatements T_CURLY_CLOSE semi
                                ;

switchCondition                 : switchValue
                                | T_PAREN_OPEN switchValue T_PAREN_CLOSE
                                ;

switchValue                     : T_IDENTIFIER
                                | T_INTEGER
                                | T_FLOAT64
                                | T_STRING
                                | 
                                ;

switchCaseStatements            : switchCaseStatement switchCaseStatements
                                |
                                ;

switchCaseStatement             : T_CASE expressions T_COLON statements switchEnd
                                | T_DEFAULT T_COLON statements
                                ;

switchEnd                       : T_BREAK
                                | T_FALLTHROUGH
                                |
                                ;



/**********************ARRAY DECLARATION**********************/
arrays                          : T_VAR array type arrDerinition semi
                                ;
 
array                           : T_IDENTIFIER T_BRACKET_OPEN arraylength T_BRACKET_CLOSE
                                ;

arrDerinition                   : T_CURLY_OPEN arrayvalues T_CURLY_CLOSE
                                |
                                ;

arraylength                     : ariphmetic
                                |
                                ;

arrayvalues                     : value
                                | arrayvalues T_COMMA value
                                ;

shortArray                      : T_BRACKET_OPEN arraylength T_BRACKET_CLOSE pointerType T_CURLY_OPEN expressions T_CURLY_CLOSE
                                | T_BRACKET_OPEN arraylength T_BRACKET_CLOSE pointerType T_CURLY_OPEN structFilling T_CURLY_CLOSE
                                | T_BRACKET_OPEN arraylength T_BRACKET_CLOSE pointerType T_CURLY_OPEN T_CURLY_CLOSE
                                | T_BRACKET_OPEN arraylength T_BRACKET_CLOSE pointerType


/**********************VARIABLE ASSIGNMENT**********************/
variableAssignment              : varIdentifier operator variableEx varExpr semi
                                ;

variableEx                      : shortArray
                                | structures
                                | expressions
                                ;

varExpr                         : T_COMMA variableEx varExpr
                                |
                                ;

operator                        : T_WALRUS
                                | T_ASSIGN
                                | T_SMINUS
                                | T_SPLUS
                                | T_SMOD
                                | T_SMUL
                                | T_SDIV
                                ;



/**********************ARRAY ASSIGNMENT**********************/
arrayAssignment                 : array T_ASSIGN expressions semi
                                ;



/**********************CICLES**********************/
cicles                          : T_FOR cicle cicleBody semi
                                ;

cicle                           : counter T_SEMI condition T_SEMI changer
                                | T_SEMI condition T_SEMI
                                | condition
                                |
                                ;

counter                         : T_IDENTIFIER T_WALRUS number
                                ;

condition                       : cicleVariables conditionOperator cicleCounters
                                ;

conditionOperator               : expressionSign
                                | T_WALRUS
                                ;

cicleVariables                  : T_IDENTIFIER cicleComma
                                | T_UNDER cicleComma
                                ;

cicleComma                      : T_COMMA cicleVariables
                                |
                                ;

cicleCounters                   : T_RANGE rangeEnd
                                | functions
                                | T_IDENTIFIER
                                | T_INTEGER
                                | T_FLOAT64
                                | T_STRING
                                ;                              

rangeEnd                        : functions
                                | T_IDENTIFIER
                                ;

changer                         : T_IDENTIFIER T_PLUS T_PLUS
                                ;

cicleBody                       : T_CURLY_OPEN statements T_CURLY_CLOSE
                                |
                                ;



/**********************STRUCT ASSIGNMENT**********************/

structures                      : T_IDENTIFIER structExpression
                                | T_BAND T_IDENTIFIER structExpression
                                ;

structExpression                : T_CURLY_OPEN structFilling T_CURLY_CLOSE
                                ;

structFilling                   : doubleFilling
                                | onceFilling
                                |
                                ;

doubleFilling                   : T_IDENTIFIER T_COLON logic doubleFillingEnd
                                | T_IDENTIFIER T_COLON structures doubleFillingEnd
                                | T_IDENTIFIER T_COLON functions doubleFillingEnd
                                ;

doubleFillingEnd                : T_COMMA doubleFilling
                                | T_COMMA
                                |
                                ;

onceFilling                     : logic onceFillingEnd
                                | structures onceFillingEnd
                                | functions onceFillingEnd
                                ;

onceFillingEnd                  : T_COMMA onceFilling  
                                | T_COMMA
                                |
                                ;


/**********************OTHER CONSTRUCTIONS**********************/
expressions                     : expression expressionEnd
                                ;

expressionEnd                   : expressionSign expressions   
                                |
                                ;

expressionSign                  : T_SAND
                                | T_SOR
                                | T_NOTEQ
                                | T_COMP
                                | T_LTE
                                | T_GTE
                                | T_AND
                                | T_OR
                                | T_LT
                                | T_GT
                                ;

expression                      : T_BNOT exprWithoutNot 
                                | exprWithoutNot
                                ;

exprWithoutNot                  : logic
                                | functions
                                ;


logic                           : logicComponent logicEnd
                                ;

logicEnd                        : T_BAND logic
                                | T_BOR logic
                                | T_BXOR logic
                                |
                                ;

logicComponent                  : T_PAREN_OPEN exprWithoutNot T_PAREN_CLOSE 
                                | bool
                                | ariphmetic
                                ;

ariphmetic                      : ariphmeticComponent ariphmeticEnd
                                ;

ariphmeticEnd                   : T_MUL ariphmetic
                                | T_DIV ariphmetic
                                | T_MOD ariphmetic
                                | T_PLUS ariphmetic
                                | T_MINUS ariphmetic
                                |
                                ;

ariphmeticComponent             : T_PAREN_OPEN expressions T_PAREN_CLOSE
                                | id
                                | T_IDENTIFIER arrayExpression
                                | number
                                | T_STRING
                                ;

arrayExpression                 : T_BRACKET_OPEN arrayIndex T_BRACKET_CLOSE
                                ;

arrayIndex                      : ariphmetic
                                | arraySize
                                ;

arraySize                       : T_INTEGER T_COLON arraySizeEnd
                                | T_COLON T_INTEGER
                                ;

arraySizeEnd                    : T_INTEGER
                                |
                                ;

%%

extern void yyerror(char* si){
    printf("%s at line number %d\n",si,yylineno);
    printf("Last token %s\n",yytext);
    valid=0;
}

int main(int argc, char * argv[]){
    if(argc >=2){
        yyin=fopen(argv[1],"r");
        if(!yyin){
            printf("Can't open input file!\n");
            exit(-1);
        }
    }
    else{
        printf("The input file was expected!\n");
    }
    //yydebug = 1;
    int accepted = yyparse();
    if(accepted==0 && valid!=0)
        printf("[+] Test passed\n");
    else
        printf("[-] Test failed\n");
    return 0;
}
