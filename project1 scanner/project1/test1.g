lexer grammar test1;

options{
	language = Java;


}

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
ALIGNAS_TYPE :'_Alignas';
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
/*    Pointer operators      */
/*---------------------------*/
POINTER_OPERATORS_TYPE:('*'('*')*|
'&' | '->' | '.' | '->*' | '.*');

/*---------------------------*/
/*    Arithmetic Operators   */
/*---------------------------*/
ARITHMETIC_OPERATORS_TYPE:('+' | '-' |'*'| 
'/' | '%' | '++' | '--');

/*---------------------------*/
/*    COMPARISON Operators   */
/*---------------------------*/
COMPARISON_OPERATORS_TYPE:('==' | '!=' | '>'| '<' | '<=' | '>=');

/*---------------------------*/
/*    Logical Operators      */
/*---------------------------*/
LOGICAL_OPERATORS_TYPE:('!' | '||' | '&&');

/*---------------------------*/
/*    Bitwise operators      */
/*---------------------------*/
BITWISE_OPERATORS_TYPE:('~' | 
'&' | '|' | '^' | '<<' | '>>');


/*---------------------------*/
/*    Assignment Operators   */
/*---------------------------*/
ASSIGNMENT_OPERATORS_TYPE:('=' | '+=' |  
'-=' | '/=' | '*=' | '%=' | '&=' | '|=' | 
'^=' | '<<=' | '>>=');

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
FLOAT_NUM:FLOAT_NUM1 |FLOAT_NUM2 |FLOAT_NUM3;
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
COMMENT:'/*' ( options {greedy=false;} : . )* '*/'{$channel=HIDDEN;};
LINE_COMMENT: '//'(.)*'\n' {$channel=HIDDEN;};

WS  :  (' '|'\r'|'\t') {$channel=HIDDEN;};
COMMA:',';
SEMICOLON:';';
COLON:':';
NEW_LINE: '\n' ;
POUND_SIGN: '#';


















