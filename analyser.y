identifier:
	LETTER { LETTER | DIGIT }
	;
	
Type:
	TypeName [ TypeArgs ]
	| TypeLit
	| REGULAR_BRACKET_LEFT Type REGULAR_BRACKET_RIGHT
	;
	
TypeName:
	identifier
	| QualifiedIdent
	;
	
TypeArgs:
	SQUARE_BRACKET_LEFT TypeList [ COMMA ] SQUARE_BRACKET_RIGHT
	;
	
TypeList:
	Type { COMMA Type }
	;
	
TypeLit:
	ArrayType
	| StructType
	| PointerType
	| FunctionType
	| InterfaceType
	| SliceType
	| MapType
	| ChannelType
	;
	
ArrayType:
	SQUARE_BRACKET_LEFT ArrayLength SQUARE_BRACKET_RIGHT ElementType
	;
	
ArrayLength:
	Expression
	;
	
ElementType:
	Type
	;
	
SliceType:
	SQUARE_BRACKET_LEFT SQUARE_BRACKET_RIGHT ElementType
	;
	
StructType:
	STRUCT CURLY_BRACKET_LEFT { FieldDecl SEMICOLON } CURLY_BRACKET_RIGHT
	;
	
FieldDecl:
	(IdentifierList Type | EmbeddedField) [ Tag ]
	;
	
EmbeddedField:
	[ ASTERISK ] TypeName
	;
	
Tag:
	STRING
	;
	
PointerType:
	ASTERISK BaseType
	;
	
BaseType:
	Type
	;
	
FunctionType:
	FUNC Signature
	;
	
Signature:
	Parameters [ Result ]
	;
	
Result:
	Parameters
	| Type
	;
Parameters:
	REGULAR_BRACKET_LEFT [ ParameterList [ COMMA ] ] REGULAR_BRACKET_RIGHT
	;
	
ParameterList:
	ParameterDecl { COMMA ParameterDecl }
	;
	
ParameterDecl:
	[ IdentifierList ] [ ELLIPSIS ] Type
	;
	
InterfaceType:
	"interface" CURLY_BRACKET_LEFT { InterfaceElem SEMICOLON } CURLY_BRACKET_RIGHT
	;
	
InterfaceElem :
	MethodElem
	| TypeElem
	;
	
MethodElem:
	MethodName Signature
	;
	
MethodName:
	identifier
	;
	
TypeElem:
	TypeTerm { LOGICAL_SINGS TypeTerm }
	;
	
TypeTerm:
	Type
	| UnderlyingType
	;
	
UnderlyingType:
	TILDE Type
	;
	
MapType:
	MAP SQUARE_BRACKET_LEFT KeyType SQUARE_BRACKET_RIGHT ElementType
	;
	
KeyType:
	Type
	;
	
ChannelType:
	( CHAN | CHAN BACK_ARROW | BACK_ARROW CHAN ) ElementType
	;
	
Block:
	CURLY_BRACKET_LEFT StatementList CURLY_BRACKET_RIGHT
	;
	
StatementList:
	{ Statement SEMICOLON }
	;
	
Declaration:
	ConstDecl
	| TypeDecl
	| VarDecl
	;
	
TopLevelDecl:
	Declaration
	| FunctionDecl
	| MethodDecl
	;
	
ConstDecl:
	CONST ( ConstSpec | REGULAR_BRACKET_LEFT { ConstSpec SEMICOLON } REGULAR_BRACKET_RIGHT )
	;
	
ConstSpec:
	IdentifierList [ [ Type ] EQUAL ExpressionList ]
	;

IdentifierList:
	identifier { COMMA identifier }
	;
	
ExpressionList:
	Expression { COMMA Expression }
	;
	
TypeDecl:
	TYPE ( TypeSpec | REGULAR_BRACKET_LEFT { TypeSpec SEMICOLON } REGULAR_BRACKET_RIGHT )
	;
	
TypeSpec:
	AliasDecl
	| TypeDef
	;
	
AliasDecl:
	identifier EQUAL Type
	;
	
TypeDef:
	identifier [ TypeParameters ] Type
	;
	
TypeParameters:
	SQUARE_BRACKET_LEFT TypeParamList [ COMMA ] SQUARE_BRACKET_RIGHT
	;
	
TypeParamList:
	TypeParamDecl { COMMA TypeParamDecl }
	;
	
TypeParamDecl:
	IdentifierList TypeConstraint
	;
	
TypeConstraint:
	TypeElem
	;
	
VarDecl:
	VAR ( VarSpec | REGULAR_BRACKET_LEFT { VarSpec SEMICOLON } REGULAR_BRACKET_RIGHT )
	;
	
VarSpec:
	IdentifierList ( Type [ EQUAL ExpressionList ] | EQUAL ExpressionList )
	;
	
ShortVarDeclЖ
	IdentifierList DEFINE ExpressionList
	;
	
FunctionDecl:
	FUNC FunctionName [ TypeParameters ] Signature [ FunctionBody ]
	;
	
FunctionName:
	identifier
	;
	
FunctionBody:
	Block
	;
	
MethodDecl:
	FUNC Receiver MethodName Signature [ FunctionBody ]
	;
	
Receiver:
	Parameters
	;
	
MethodDecl:
	FUNC Receiver MethodName Signature [ FunctionBody ]
	;
	
Receiver:
	Parameters
	;
	
Operand:
	Literal
	| OperandName [ TypeArgs ]
	| REGULAR_BRACKET_LEFT Expression REGULAR_BRACKET_RIGHT
	;
	
Literal:
	BasicLit
	| CompositeLit
	| FunctionLit
	;
	
BasicLit:
	int_lit
	| float_lit
	| imaginary_lit
	| rune_lit
	| STRING
	;

OperandName:
	identifier
	| QualifiedIdent
	;

QualifiedIdent:
	PackageName PERIOD identifier
	;

CompositeLit:
	LiteralType LiteralValue
	;
	
LiteralType:
	StructType
	| ArrayType
	| SQUARE_BRACKET_LEFT ELLIPSIS SQUARE_BRACKET_RIGHT ElementType
	| SliceType
	| MapType
	| TypeName
	;
	
LiteralValue:
	CURLY_BRACKET_LEFT [ ElementList [ COMMA ] ] CURLY_BRACKET_RIGHT
	;
	
ElementList:
	KeyedElement { COMMA KeyedElement }
	;
	
KeyedElement:
	[ Key COLON ] Element
	;
	
Key:
	FieldName
	| Expression
	| LiteralValue
	;
	
FieldName:
	identifier
	;
	
Element:
	Expression
	| LiteralValue
	;
	
FunctionLit:
	FUNC Signature FunctionBody
	;
	
MethodExpr:
	ReceiverType PERIOD MethodName
	;
	
ReceiverType:
	Type
	;

Expression:
	UnaryExpr
	| Expression COMPARISON_SIGN Expression
	;
	
UnaryExpr:
	PrimaryExpr
	| MATH_SIGN UnaryExpr
	;

Conversion:
	Type REGULAR_BRACKET_LEFT Expression [ COMMA ] REGULAR_BRACKET_RIGHT
	;

Statement:
	Declaration
	| LabeledStmt
	| SimpleStmt
	| GoStmt
	| ReturnStmt
	| BreakStmt
	| ContinueStmt
	| GotoStmt
	| FallthroughStmt
	| Block
	| IfStmt
	| SwitchStmt
	| ForStmt
	| DeferStmt
	;

SimpleStmt:
	EmptyStmt
	| ExpressionStmt
	| SendStmt
	| IncDecStmt
	| Assignment
	| ShortVarDecl
	;
	
EmptyStmt:
	;
	
LabeledStmt:
	Label COLON Statement
	;
	
Label:
	identifier
	;
	
ExpressionStmt:
	Expression
	;
	
SendStmt:
	Channel BACK_ARROW Expression
	;
	
Channel:
	Expression
	;
	
IncDecStmt:
	Expression ( UNO_OPERATION )
	;
	
Assignment:
	ExpressionList assign_op ExpressionList
	;

assign_op:
	[ MATH_SIGN | ASTERISK | LOGICAL_SINGS ] EQUAL
	;

IfStmt:
	IF [ SimpleStmt SEMICOLON ] Expression Block [ ELSE ( IfStmt | Block ) ]
	;

SwitchStmt:
	ExprSwitchStmt
	| TypeSwitchStmt
	;

ExprSwitchStmt:
	SWITCH [ SimpleStmt SEMICOLON ] [ Expression ] CURLY_BRACKET_LEFT { ExprCaseClause } CURLY_BRACKET_RIGHT
	;
	
ExprCaseClause:
	ExprSwitchCase COLON StatementList
	;
	
ExprSwitchCase:
	CASE ExpressionList
	| DEFAULT
	;

TypeSwitchStmt:
	SWITCH [ SimpleStmt SEMICOLON ] TypeSwitchGuard CURLY_BRACKET_LEFT { TypeCaseClause } CURLY_BRACKET_RIGHT
	;
	
TypeSwitchGuard:
	[ identifier DEFINE ] PrimaryExpr PERIOD REGULAR_BRACKET_LEFT TYPE REGULAR_BRACKET_RIGHT
	;
	
TypeCaseClause:
	TypeSwitchCase COLON StatementList
	;
	
TypeSwitchCase:
	CASE TypeList
	| DEFAULT
	;

ForStmt:
	FOR [ Condition | ForClause | RangeClause ] Block
	;
	
Condition:
	Expression
	;

ForClause:
	[ InitStmt ] SEMICOLON [ Condition ] SEMICOLON [ PostStmt ]
	;
	
InitStmt:
	SimpleStmt
	;
	
PostStmt:
	SimpleStmt
	;

RangeClause:
	[ ExpressionList EQUAL | IdentifierList DEFINE ] RANGE Expression
	;

GoStmt:
	GO Expression
	;

ReturnStmt:
	RETURN [ ExpressionList ]
	;

BreakStmt:
	BREAK [ Label ]
	;

ContinueStmt:
	CONTINUE [ Label ]
	;

GotoStmt:
	GOTO Label
	;

FallthroughStmt:
	FALLTHROUGH
	;

DeferStmt:
	DEFER Expression
	;

SourceFile:
	PackageClause SEMICOLON { ImportDecl SEMICOLON } { TopLevelDecl SEMICOLON }
	;

PackageClause:
	PACKAGE PackageName
	;
	
PackageName:
	identifier
	;

ImportDecl:
	IMPORT ( ImportSpec | REGULAR_BRACKET_LEFT { ImportSpec SEMICOLON } REGULAR_BRACKET_RIGHT )
	;
	
ImportSpec:
	[ PERIOD | PackageName ] ImportPath
	;
	
ImportPath:
	STRING
	;