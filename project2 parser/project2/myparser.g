grammar myparser;

options {
     language = Java;
}

@header {
    // import packages here.
}

@members {
    boolean TRACEON = true;
}
    
////////////////// Start symbol　//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

program:(POUND_SIGN'include' '<' ID '.h>') *begin {if (TRACEON) System.out.println("use header or not");};
begin:( type_specifier ID ( '(' (type_specifier ID (COMMA)*)*  ')' (';'| '{' declarations statements'}'))*)*
        {if (TRACEON) System.out.println("function type  () { statements}");};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////




////////////////// Declartion　/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
declarations:(type  declarations)    | ;

type
    : 'typedef'  declaration_specifiers? init_declarator_list SEMICOLON {if (TRACEON) System.out.println("typedef declarations");}// special case, looking for typedef	
    | declaration_specifiers init_declarator_list? SEMICOLON
    ;

declaration_specifiers
    :   (     storage_class_specifier
	      | type_specifier
	      | type_qualifier
        )+
    ;

init_declarator_list
    : init_declarator (COMMA init_declarator)*
    ;

init_declarator
    : declarator ( ASSIGNMENT_OPERATORS_TYPE  initializer)?
    ;

storage_class_specifier
    : EXTERN_TYPE{if (TRACEON) System.out.println("type:extern");}
    | STATIC_TYPE{if (TRACEON) System.out.println("type:static");}
    | AUTO_TYPE{if (TRACEON) System.out.println("type:auto");}
    | REGISTER_TYPE{if (TRACEON) System.out.println("type:register");}
    ;
type_specifier
    : VOID_TYPE{if (TRACEON) System.out.println("type:void");}
    | CHAR_TYPE{if (TRACEON) System.out.println("type:char");}
    | SHORT_TYPE{if (TRACEON) System.out.println("type:short");}
    | INT_TYPE{if (TRACEON) System.out.println("type:int");}
    | LONG_TYPE{if (TRACEON) System.out.println("type:long");}
    | FLOAT_TYPE  {if (TRACEON) System.out.println("type:float");}
    | DOUBLE_TYPE{if (TRACEON) System.out.println("type:double");}
    | SIGNED_TYPE{if (TRACEON) System.out.println("type:signed");}
    | UNSIGNED_TYPE{if (TRACEON) System.out.println("type:unsigned");}
    | struct_or_union_specifier
    | enum_specifier
    ;

type_qualifier
    : CONST_TYPE {if (TRACEON) System.out.println("type:const ");}
    | VOLATILE_TYPE {if (TRACEON) System.out.println("type:volatile ");}
    ;
declarator:
	pointer ID {if (TRACEON) System.out.println(  $pointer.text + $ID.text);}
        |ID {if (TRACEON) System.out.println(   $ID.text);}
	|ID ('['constant']')+ {if (TRACEON) System.out.println("array declartion " + $ID.text);};
pointer
    : ('*')+ {if (TRACEON) System.out.println("type:pointer "); }
    ;
initializer:
	('-')?ID
        | pointer ID
        |('-')?constant
        |('-')?OP_CURLY_BRACKET constant(COMMA constant)* CL_CURLY_BRACKET;

struct_or_union_specifier
    : struct_or_union ID? OP_CURLY_BRACKET struct_declaration_list CL_CURLY_BRACKET  {if (TRACEON) System.out.println($ID.text );}
    | struct_or_union ID  {if (TRACEON) System.out.println($ID.text );}
    ;
struct_or_union
    : STRUCT_TYPE {if (TRACEON) System.out.println("struct declartion " );} 
    | UNION_TYPE {if (TRACEON) System.out.println("union declartion ");}
    ;

struct_declaration_list
    : struct_declaration+
    ;

struct_declaration
    : specifier_qualifier_list struct_declarator_list SEMICOLON
    ;

specifier_qualifier_list
    : ( type_qualifier | type_specifier )+
    ;

struct_declarator_list
    : struct_declarator (COMMA struct_declarator)*
    ;

struct_declarator
    : declarator (COLON constant_expression)?
    | COLON constant_expression
    ;
enum_specifier
    : ENUM_TYPE OP_CURLY_BRACKET enumerator_list CL_CURLY_BRACKET {if (TRACEON) System.out.println("enum declartion ");}
    | ENUM_TYPE ID OP_CURLY_BRACKET enumerator_list CL_CURLY_BRACKET {if (TRACEON) System.out.println("enum declartion " + $ID.text);}
    | ENUM_TYPE ID {if (TRACEON) System.out.println("enum declartion " + $ID.text);}
    ;

enumerator_list
    : enumerator (COMMA enumerator)*
    ;

enumerator
    : ID (ASSIGNMENT_OPERATORS_TYPE constant_expression)?
    ;
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


////////////////// Expression　///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
argument_expression_list
    :   assignment_expression (COMMA assignment_expression)*
    ;

additive_expression
    : multExpr('+' multExpr | '-' multExpr)*
    ;

multExpr
    : (postfix_expression) ('*' postfix_expression | '/' postfix_expression | '%' postfix_expression)*
    ;

unary_expression
    :  ID(    
			 '(' ')'
			| '.' ID { if (TRACEON) System.out.println("struct_expression"); }
			| '->' ID { if (TRACEON) System.out.println("pointer_expression"); }
			| '++' { if (TRACEON) System.out.println("operation: ++"); }
			| '--' { if (TRACEON) System.out.println("operation: --"); }
        )*
    ;

postfix_expression
    :   ('-'primary_expression
	|primary_expression)(     '[' expression ']'
			| '(' ')'
			| '(' argument_expression_list ')'{if (TRACEON) System.out.println("type: function_call_list"); }
			| '.' ID
			| '->' ID
			| '++'
		        | '--'		
        )*
		
    ;

primary_expression
    : ID 
    | constant
    |'(' additive_expression ')'
    ;


constant
    :   HEX_NUM 
    |   OCTAL_NUM
    |   DECIMAL_NUM
    |	STRING
    |   FLOAT_NUM
    ;

expression
    : assignment_expression (',' assignment_expression)*
    ;
constant_expression
    : conditional_expression
    ;
assignment_expression
    : lvalue ASSIGNMENT_OPERATORS_TYPE assignment_expression 
    | conditional_expression 
    |'++'unary_expression { if (TRACEON) System.out.println("operation: ++"); }
    |'--'unary_expression { if (TRACEON) System.out.println("operation: --"); }
    ;
/*---------------------------*/
/*    Assignment Operators   */
/*---------------------------*/
ASSIGNMENT_OPERATORS_TYPE: '='
    | '*='
    | '/='
    | '%='
    | '+='
    | '-='
    | '<<='
    | '>>='
    | '&='
    | '^='
    | '|=';

lvalue
    :	unary_expression
    ;


conditional_expression 
    : logical_or_expression ('?' expression ':' conditional_expression)? 
    ;

logical_or_expression
    : logical_and_expression ('||' logical_and_expression)*
    ;

logical_and_expression
    : inclusive_or_expression ('&&' inclusive_or_expression)*
    ;

inclusive_or_expression
    : exclusive_or_expression ('|' exclusive_or_expression)*
    ;

exclusive_or_expression
    : and_expression ('^' and_expression)*
    ;

and_expression
    : equality_expression ('&' equality_expression)*
    ;

equality_expression
    : relational_expression (('==' | '!=') relational_expression)* 
    ;

relational_expression
    : shift_expression (('<'|'>' | '<=' | '>=') shift_expression)*
    ;

shift_expression
    : additive_expression (('<<' | '>>') additive_expression)*
    ;

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


////////////////// STATAMENTS　///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

statements:statement statements
        |;

statement
    : label_statement 
    | selection_statement 
    | iteration_statement
    | jump_statement 
    | compound_statement
    | expression_statement  
    | 'printf' OP_PARENTHESIS (STRING (COMMA ID)*) CL_PARENTHESIS { if (TRACEON) System.out.println("print: " + $STRING.text + $ID.text);}
    ;

label_statement 
    : ID COLON statement { if(TRACEON) System.out.println("ID :"); }
    | CASE_TYPE conditional_expression COLON statement { if(TRACEON) System.out.println("type: case"); }
    | DEFAULT_TYPE COLON statement { if(TRACEON) System.out.println("type: default"); }
    ;

expression_statement
    : SEMICOLON   
    | expression SEMICOLON  
    ;
compound_statement
    : OP_CURLY_BRACKET  declarations statement_list? CL_CURLY_BRACKET { if(TRACEON) System.out.println("type: compound_statement"); }
    ;
statement_list
    : statement+
    ;
selection_statement 
    : IF_TYPE OP_PARENTHESIS expression CL_PARENTHESIS statement  (('else')=> 'else' statement)? { if(TRACEON) System.out.println("type: IF_TYPE");}
    | SWITCH_TYPE OP_PARENTHESIS expression CL_PARENTHESIS statement { if(TRACEON) System.out.println("type: switch_TYPE"); }
    ;


jump_statement
    : GOTO_TYPE ID SEMICOLON  { if(TRACEON) System.out.println("type: goto_TYPE"); }
    | CONTINUE_TYPE SEMICOLON  { if(TRACEON) System.out.println("type: contiune_TYPE"); }
    | BREAK_TYPE SEMICOLON { if(TRACEON) System.out.println("type: break_TYPE"); }
    | RETURN_TYPE SEMICOLON { if(TRACEON) System.out.println("type: return_TYPE"); }
    | RETURN_TYPE expression SEMICOLON { if(TRACEON) System.out.println("type: return_expression_TYPE"); }
    ;
iteration_statement
    : WHILE_TYPE OP_PARENTHESIS expression CL_PARENTHESIS statement   { if(TRACEON) System.out.println("type: while_TYPE"); }
    | DO_TYPE statement WHILE_TYPE OP_PARENTHESIS expression CL_PARENTHESIS SEMICOLON  { if(TRACEON) System.out.println("type: do_while_TYPE"); }
    | FOR_TYPE OP_PARENTHESIS expression_statement expression_statement expression? CL_PARENTHESIS statement  { if(TRACEON) System.out.println("type: for_loop_TYPE"); }
    ;

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*---------------------------*/
/*          Keywords         */
/*---------------------------*/
AUTO_TYPE :'auto';
BREAK_TYPE :'break';
CASE_TYPE :'case';
CHAR_TYPE :'char';
CONST_TYPE :'const';
CONTINUE_TYPE :'continue';
DEFAULT_TYPE :'default';
DO_TYPE :'do';
DOUBLE_TYPE :'double';
FLOAT_TYPE :'float';
ELSE_TYPE :'else';
ENUM_TYPE :'enum';
EXTERN_TYPE :'extern';
FOR_TYPE :'for';
GOTO_TYPE :'goto';
IF_TYPE :'if';
INT_TYPE :'int';
INLINE_TYPE :'inline';
LONG_TYPE :'long';
REGISTER_TYPE :'register';
RESTRICT_TYPE :'restrict';
RETURN_TYPE :'return';
SHORT_TYPE :'short';
SIGNED_TYPE :'signed';
SIZEOF_TYPE :'sizeof';
STATIC_TYPE :'static';
STRUCT_TYPE :'struct';
SWITCH_TYPE :'switch';
TYPEDEF_TYPE :'typedef';
UNION_TYPE :'union';
UNSIGNED_TYPE :'unsigned';
VOID_TYPE :'void';
VOLATILE_TYPE :'volatile';
WHILE_TYPE :'while';
ALIGNAS_TYPE :'_Alignas' ;
ALIGNOF_TYPE :'_Alignof';
ATOMIC_TYPE :'_Atomic';
BOOL_TYPE :'_Bool';
COMPLEX_TYPE :'_Complex';
DECIMAL128 :'_Decimal128';
DECIMAL32 :'_Decimal32';
DECIMAL64 :'_Decimal64';
GENERIC_TYPE :'_Generic';
IMAGINARY_TYPE :'_Imaginary';
NORETURN_TYPE :'_Noreturn';
STATIC_ASSERT_TYPE :'_Static_assert';
THREAD_LOCAL_TYPE :'_Thread_local';

/*---------------------------*/
/*    	Parenthesis          */
/*---------------------------*/
OP_PARENTHESIS:'(';
CL_PARENTHESIS:')';
OP_CURLY_BRACKET:'{';
CL_CURLY_BRACKET:'}';
OP_SQUARE_BRACKETS:'[';
CL_SQUARE_BRACKETS:']';

/*---------------------------*/
/*    	    String	     */
/*---------------------------*/
STRING:('"'(.)*'"');

/*---------------------------*/
/*    	 Identifier          */
/*---------------------------*/
ID : LETTER (LETTER|'0'..'9')*;

/*---------------------------*/
/*    	   Number            */
/*---------------------------*/
FLOAT_NUM:FLOAT_NUM1 |FLOAT_NUM2 |FLOAT_NUM3 ;
fragment FLOAT_NUM1 : (DECIMAL_NUM)+'.'(DIGIT)+Exponent? FloatTypeSuffix?;
fragment FLOAT_NUM2 : '.'(DIGIT)+Exponent? FloatTypeSuffix?;
fragment FLOAT_NUM3 : (DIGIT)+ Exponent FloatTypeSuffix?;

HEX_NUM : '0' ('x'|'X') HexDigit+ IntegerTypeSuffix? ;
DECIMAL_NUM : ('0' | '1'..'9'(DIGIT)*) IntegerTypeSuffix? ;
OCTAL_NUM : '0' ('0'..'7')+ IntegerTypeSuffix? ;
fragment HexDigit : ( DIGIT |'a'..'f'|'A'..'F') ;
fragment IntegerTypeSuffix : ('l'|'L')|('u'|'U')('l'|'L')?;

fragment Exponent : ('e'|'E') ('+'|'-')? (DIGIT)+ ;
fragment FloatTypeSuffix : ('f'|'F'|'d'|'D') ;
fragment OctalEscape:'\\' ('0'..'3') ('0'..'7') ('0'..'7')|'\\' ('0'..'7') ('0'..'7')|'\\' ('0'..'7');
fragment UnicodeEscape:'\\' 'u' HexDigit HexDigit HexDigit HexDigit;
fragment DIGIT : '0'..'9'; 
fragment LETTER : 'a'..'z' | 'A'..'Z' | '_';


/* Comments */
COMMENT:'/*' ( options {greedy=false;} : . )* '*/'{$channel=HIDDEN;} ;
LINE_COMMENT: '//'(.)*'\n' {$channel=HIDDEN;};

WS  :  (' '|'\r'|'\t') {$channel=HIDDEN;};
COMMA:',';
SEMICOLON:';';
COLON:':';
NEW_LINE: '\n' {$channel=HIDDEN;};
POUND_SIGN: '#';


















