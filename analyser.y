identifier:
	LETTER { LETTER | DIGIT }
	;
	
Type:
	TypeName [ TypeArgs ]
	| TypeLit
	| "(" Type ")"
	;
	
TypeName:
	identifier
	| QualifiedIdent
	;
	
TypeArgs:
	"[" TypeList [ "," ] "]"
	;
	
TypeList:
	Type { "," Type }
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
	"[" ArrayLength "]" ElementType
	;
	
ArrayLength:
	Expression
	;
	
ElementType:
	Type
	;
	
SliceType:
	"[" "]" ElementType
	;
	
StructType:
	"struct" "{" { FieldDecl ";" } "}"
	;
	
FieldDecl:
	(IdentifierList Type | EmbeddedField) [ Tag ]
	;
	
EmbeddedField:
	[ "*" ] TypeName
	;
	
Tag:
	string_lit
	;
	
PointerType:
	"*" BaseType
	;
	
BaseType:
	Type
	;
	
FunctionType:
	"func" Signature
	;
	
Signature:
	Parameters [ Result ]
	;
	
Result:
	Parameters
	| Type
	;
Parameters:
	"(" [ ParameterList [ "," ] ] ")"
	;
	
ParameterList:
	ParameterDecl { "," ParameterDecl }
	;
	
ParameterDecl:
	[ IdentifierList ] [ "..." ] Type
	;
	
InterfaceType:
	"interface" "{" { InterfaceElem ";" } "}"
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
	TypeTerm { "|" TypeTerm }
	;
	
TypeTerm:
	Type
	| UnderlyingType
	;
	
UnderlyingType:
	"~" Type
	;
	
MapType:
	"map" "[" KeyType "]" ElementType
	;
	
KeyType:
	Type
	;
	
ChannelType:
	( "chan" | "chan" "<-" | "<-" "chan" ) ElementType
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
	"const" ( ConstSpec | "(" { ConstSpec ";" } ")" )
	;
	
ConstSpec:
	IdentifierList [ [ Type ] "=" ExpressionList ]
	;

IdentifierList:
	identifier { "," identifier }
	;
	
ExpressionList:
	Expression { "," Expression }
	;
	
TypeDecl:
	"type" ( TypeSpec | "(" { TypeSpec ";" } ")" )
	;
	
TypeSpec:
	AliasDecl
	| TypeDef
	;
	
AliasDecl:
	identifier "=" Type
	;
	
TypeDef:
	identifier [ TypeParameters ] Type
	;
	
TypeParameters:
	"[" TypeParamList [ "," ] "]"
	;
	
TypeParamList:
	TypeParamDecl { "," TypeParamDecl }
	;
	
TypeParamDecl:
	IdentifierList TypeConstraint
	;
	
TypeConstraint:
	TypeElem
	;
	
VarDecl:
	"var" ( VarSpec | "(" { VarSpec ";" } ")" )
	;
	
VarSpec:
	IdentifierList ( Type [ "=" ExpressionList ] | "=" ExpressionList )
	;
	
ShortVarDeclЖ
	IdentifierList ":=" ExpressionList
	;
	
FunctionDecl:
	"func" FunctionName [ TypeParameters ] Signature [ FunctionBody ]
	;
	
FunctionName:
	identifier
	;
	
FunctionBody:
	Block
	;
	
MethodDecl:
	"func" Receiver MethodName Signature [ FunctionBody ]
	;
	
Receiver:
	Parameters
	;
	
MethodDecl:
	"func" Receiver MethodName Signature [ FunctionBody ]
	;
	
Receiver:
	Parameters
	;