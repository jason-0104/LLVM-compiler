grammar myChecker;

options {
     language = Java;
}

@header {
    // import packages here.
	import java.util.HashMap;
}

@members {
    boolean TRACEON = false;
    HashMap<String,Integer> symtab = new HashMap<String,Integer>();
}
    
////////////////// Start symbol　//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

program:(POUND_SIGN'include' '<' ID '.h>') *begin {if (TRACEON) System.out.println("use header or not");};
begin:( type_specifier ID ( '(' (type_specifier ID (COMMA)*)*  ')' (';'| '{' declarations statements'}'))*)*
        {if (TRACEON) System.out.println("function type  () { statements}");};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////




////////////////// Declartion　/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
declarations:(type  declarations)    | ;

type
    : 'typedef'  declaration_specifiers? x = init_declarator(COMMA x = init_declarator)* SEMICOLON {if (TRACEON) System.out.println("typedef declarations");}// special case, looking for typedef	
    {	
        String out = $x.text;
        String[] parts = out.split(" ");
		if (symtab.containsKey(parts[0])) {
			   System.out.println("Error: " + $x.start.getLine() +  ": Redeclared identifier.");
		} 
		else{
			   /* Add ID and its attr_type into the symbol table. */
               //System.out.println($declaration_specifiers.attr_type);
			   symtab.put($x.text, $declaration_specifiers.attr_type);	   
		}
        if($declaration_specifiers.attr_type!=$x.attr_type && $x.attr_type!=0 &&$x.attr_type!=-2){
            System.out.println("Error: " + 
			                    $declaration_specifiers.start.getLine() +
						         ": Type mismatch for the operator  in an expression.");
        }
	}
    | declaration_specifiers (x = init_declarator(COMMA y = init_declarator)*) SEMICOLON
    {	
        String out = $x.text;
        String[] parts = out.split(" ");
	
		if (symtab.containsKey(parts[0])) {
			   System.out.println("Error: " + $x.start.getLine() +  ": Redeclared identifier.");
		} 
		else{
			   /* Add ID and its attr_type into the symbol table. */
			   	
               //System.out.println($declaration_specifiers.attr_type); 
               symtab.put(parts[0], $declaration_specifiers.attr_type);
		}
        if($declaration_specifiers.attr_type!=$x.attr_type && $x.attr_type!=0 &&$x.attr_type!=-3&&$x.attr_type!=-2){
            System.out.println("Error: " + 
			                    $declaration_specifiers.start.getLine() +
						         ": Type mismatch for the operator assignment in an expression.");
        }
        if( $y.text!=null){
	String out1 = $y.text;
        String[] parts1 = out1.split(" ");
		
		if (symtab.containsKey(parts1[0])) {
			   System.out.println("Error: " + $y.start.getLine() +  ": Redeclared identifier.");
		} 
		else{
			   /* Add ID and its attr_type into the symbol table. */
			   	
               //System.out.println($declaration_specifiers.attr_type); 
               symtab.put(parts1[0], $declaration_specifiers.attr_type);
		}
        if($declaration_specifiers.attr_type!=$y.attr_type && $y.attr_type!=0 &&$y.attr_type!=-3&&$y.attr_type!=-2){
            System.out.println("Error: " + 
			                    $declaration_specifiers.start.getLine() +
						         ": Type mismatch for the operator assignment in an expression.");
        
	}
	}
    }
    ;

declaration_specifiers returns[int attr_type]
    : type_qualifier?
    (     storage_class_specifier  { $attr_type = $storage_class_specifier.attr_type; }
	      | type_specifier  { $attr_type = $type_specifier.attr_type; }
	         
        )+
    ;


init_declarator returns[int attr_type]
    : declarator  ( ASSIGNMENT_OPERATORS_TYPE  initializer)? {$attr_type = $initializer.attr_type;}
    ;

type_specifier returns[int attr_type]
    : VOID_TYPE{if (TRACEON) System.out.println("type:void");$attr_type = 1;} 
    | CHAR_TYPE{if (TRACEON) System.out.println("type:char");$attr_type = 2;} 
    | SHORT_TYPE{if (TRACEON) System.out.println("type:short");$attr_type = 3;}
    | INT_TYPE{if (TRACEON) System.out.println("type:int");$attr_type = 4;}
    | LONG_TYPE{if (TRACEON) System.out.println("type:long");$attr_type = 5;}
    | FLOAT_TYPE  {if (TRACEON) System.out.println("type:float");$attr_type = 6;}
    | DOUBLE_TYPE{if (TRACEON) System.out.println("type:double");$attr_type = 6;}
    | SIGNED_TYPE{if (TRACEON) System.out.println("type:signed");$attr_type = 8;}
    | UNSIGNED_TYPE{if (TRACEON) System.out.println("type:unsigned");$attr_type = 9;}
    | BOOL_TYPE{if (TRACEON) System.out.println("type:bool");$attr_type = 10;}
    | struct_or_union_specifier{if (TRACEON) System.out.println("type:bool");$attr_type = 11;}
    | enum_specifier{if (TRACEON) System.out.println("type:bool");$attr_type = 12;}
    ;

storage_class_specifier returns[int attr_type]
    : EXTERN_TYPE{if (TRACEON) System.out.println("type:extern");$attr_type = 13;}
    | STATIC_TYPE{if (TRACEON) System.out.println("type:static");$attr_type = 14;}
    | AUTO_TYPE{if (TRACEON) System.out.println("type:auto");$attr_type = 15;}
    | REGISTER_TYPE{if (TRACEON) System.out.println("type:register");$attr_type = 16;}
    ;
type_qualifier 
    : CONST_TYPE {if (TRACEON) System.out.println("type:const ");}
    | VOLATILE_TYPE {if (TRACEON) System.out.println("type:volatile ");}
    ;
declarator 
    : pointer  ID 
    |ID 
	|ID ('['constant']')+ 
	;
pointer
    : ('*')+ {if (TRACEON) System.out.println("type:pointer "); }
    ;
initializer returns[int attr_type]
    :
    | pointer ID
    {
	   if (symtab.containsKey($ID.text)) {
	       $attr_type = symtab.get($ID.text);
	   } else {
           /* Add codes to report and handle this error */
             System.out.println("Error: " + $ID.getLine() +  ": Undefined identifier : " + $ID.text);
	       $attr_type = -3;
		   return $attr_type;
	   }
    }
    |('-')?OP_CURLY_BRACKET constant(COMMA constant)* CL_CURLY_BRACKET
    |additive_expression {$attr_type = $additive_expression.attr_type; }    
    ;

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

additive_expression returns [int attr_type]
    : a = multExpr{ $attr_type = $a.attr_type; }
	('+' b = multExpr 
	{ if (($a.attr_type != $b.attr_type) &&  $a.attr_type!=-3 && $b.attr_type!=-3 &&  $a.attr_type!=-2 && $b.attr_type!=-2) {
			  System.out.println("Error: " + 
				                 $a.start.getLine() +
						         ": Type mismatch for the arithmetic operator in an expression.");
		      $attr_type = -2;
		  }
        }
	| '-' c = multExpr
	{ if ($a.attr_type != $c.attr_type  &&  $a.attr_type!=-3 && $c.attr_type!=-3 &&  $a.attr_type!=-2 && $c.attr_type!=-2) {
			  System.out.println("Error: " + 
				                 $a.start.getLine() +
						         ": Type mismatch for the arithmetic operator in an expression.");
		      $attr_type = -2;
		  }
        }
	)*
    ;

multExpr returns [int attr_type]
    :a = postfix_expression{ $attr_type = $a.attr_type; }
	('*' b = postfix_expression 
	{ if ($a.attr_type != $b.attr_type &&  $a.attr_type!=-3 && $b.attr_type!=-3 &&  $a.attr_type!=-2 && $b.attr_type!=-2  ) {
			  System.out.println("Error: " + 
				                 $a.start.getLine() +
						         ": Type mismatch for the arithmetic operator in an expression.");
		      $attr_type = -2;
		  }
        }
	| '/' c = postfix_expression 
	{ if ($a.attr_type != $c.attr_type  &&  $a.attr_type!=-3 && $c.attr_type!=-3 &&  $a.attr_type!=-2 && $c.attr_type!=-2) {
			  System.out.println("Error: " + 
				                 $a.start.getLine() +
						         ": Type mismatch for the arithmetic operator  in an expression.");
		      $attr_type = -2;
		  }
        }
	| '%' d = postfix_expression
	{ if ($a.attr_type != $d.attr_type  &&  $a.attr_type!=-3 && $d.attr_type!=-3 &&  $a.attr_type!=-2 && $d.attr_type!=-2) {
			  System.out.println("Error: " + 
				                 $a.start.getLine() +
						         ": Type mismatch for the arithmetic operator  in an expression.");
		      $attr_type = -2;
		  }
        }
        )*
    ;

unary_expression returns [int attr_type]
    :  x = ID(    
			 '(' ')'
			| '.' ID { if (TRACEON) System.out.println("struct_expression"); }
			| '->' ID { if (TRACEON) System.out.println("pointer_expression"); }
			| '++' { if (TRACEON) System.out.println("operation: ++"); }
			| '--' { if (TRACEON) System.out.println("operation: --"); }
        )*
         {
        if (symtab.containsKey($x.text)) {
            $attr_type = symtab.get($x.text);
        } else {
            /* Add codes to report and handle this error */
                System.out.println("Error: " + $x.getLine() +  ": Undefined identifier : " + $x.text);
            $attr_type = -3;
            return $attr_type;
        }
    }
    ;

postfix_expression returns [int attr_type]
    :  ('-' a = primary_expression{ $attr_type = $a.attr_type; }
	|b = primary_expression{ $attr_type = $b.attr_type; })
	(     '[' expression ']'
			| '(' ')'
			| '(' argument_expression_list ')'{if (TRACEON) System.out.println("type: function_call_list"); }
			| '.' ID
			| '->' ID
			| '++'
		    | '--'		
        )*
		
    ;

primary_expression returns [int attr_type] 
    : ID 
    {
	   if (symtab.containsKey($ID.text)) {
	       $attr_type = symtab.get($ID.text);
	   } else {
           /* Add codes to report and handle this error */
             System.out.println("Error: " + $ID.getLine() +  ": Undefined identifier : " + $ID.text);
	       $attr_type = -3;
		   return $attr_type;
	   }
    }
    |a = constant{ $attr_type = $a.attr_type; }
    |'(' additive_expression ')' { $attr_type = $additive_expression.attr_type; }
    ;


constant  returns [int attr_type]
    :   HEX_NUM  { $attr_type = 4; }
    |   OCTAL_NUM { $attr_type = 4; }
    |   DECIMAL_NUM { $attr_type = 4; }
    |	STRING { $attr_type = 2; }
    |   FLOAT_NUM { $attr_type = 6; }
    ;

expression returns [int attr_type]
    :'!'? x = assignment_expression (',' '!'? x = assignment_expression)* { $attr_type = $x.attr_type; }
    ;
constant_expression
    : conditional_expression
    ;
assignment_expression returns [int attr_type]
    : a = lvalue ASSIGNMENT_OPERATORS_TYPE c = assignment_expression 
    { if ($a.attr_type != $c.attr_type  &&  $a.attr_type!=-3 && $c.attr_type!=-3  && $c.attr_type!=-2) {
			  System.out.println("Error: " + 
				                 $a.start.getLine() +
						         ": Type mismatch for the assignment operator in an expression.");
		     //System.out.println($a.attr_type + "  " +  $c.attr_type);
		  }
       $attr_type =0;
    }
    | conditional_expression  { $attr_type = $conditional_expression.attr_type; } 
    |'++'unary_expression { if (TRACEON) System.out.println("operation: ++"); } { $attr_type = 10; }
    |'--'unary_expression { if (TRACEON) System.out.println("operation: --"); } { $attr_type = 10; }
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

lvalue returns [int attr_type]
    :	unary_expression{$attr_type = $unary_expression.attr_type;}
    ;


conditional_expression returns [int attr_type]
    : logical_or_expression ('?' expression ':' conditional_expression)?  {$attr_type = $logical_or_expression.attr_type;}
    ;

logical_or_expression  returns [int attr_type]
    : x = logical_and_expression ('||' y = logical_and_expression)* 
    { if (($x.attr_type != $y.attr_type) &&  $y.attr_type!=-3 && $x.attr_type!=-3 &&  $x.attr_type!=-2 && $y.attr_type!=-2 && $y.attr_type!=0) {
			  System.out.println("Error: " + 
				                 $x.start.getLine() +
						         ": Type mismatch for the comparison operator in an expression.");
		      $attr_type = -2;
		  }
        else
            $attr_type = $x.attr_type;
    }
    ;

logical_and_expression  returns [int attr_type]
    :x = inclusive_or_expression ('&&' y = inclusive_or_expression)*  
    { if (($x.attr_type != $y.attr_type) &&  $y.attr_type!=-3 && $x.attr_type!=-3 &&  $x.attr_type!=-2 && $y.attr_type!=-2 && $y.attr_type!=0) {
			  System.out.println("Error: " + 
				                 $x.start.getLine() +
						         ": Type mismatch for the comparison operator in an expression.");
		      $attr_type = -2;
		  }
        else
            $attr_type = $x.attr_type;
    }
    ;

inclusive_or_expression returns [int attr_type]
    : x = exclusive_or_expression ('|' y = exclusive_or_expression)*  
    { if (($x.attr_type != $y.attr_type) &&  $y.attr_type!=-3 && $x.attr_type!=-3 &&  $x.attr_type!=-2 && $y.attr_type!=-2 && $y.attr_type!=0) {
			  System.out.println("Error: " + 
				                 $x.start.getLine() +
						         ": Type mismatch for the comparison operator in an expression.");
		      $attr_type = -2;
		  }
        else
            $attr_type = $x.attr_type;
    }
    ;

exclusive_or_expression  returns [int attr_type]
    : x = and_expression ('^' y = and_expression)* 
    { if (($x.attr_type != $y.attr_type) &&  $y.attr_type!=-3 && $x.attr_type!=-3 &&  $x.attr_type!=-2 && $y.attr_type!=-2 && $y.attr_type!=0) {
			  System.out.println("Error: " + 
				                 $x.start.getLine() +
						         ": Type mismatch for the comparison operator in an expression.");
		      $attr_type = -2;
		  }
        else
            $attr_type = $x.attr_type;
    }
    ;

and_expression returns [int attr_type]
    : x = equality_expression ('&' y = equality_expression)*  
    { if (($x.attr_type != $y.attr_type) &&  $y.attr_type!=-3 && $x.attr_type!=-3 &&  $x.attr_type!=-2 && $y.attr_type!=-2 && $y.attr_type!=0) {
			  System.out.println("Error: " + 
				                 $x.start.getLine() +
						         ": Type mismatch for the comparison operator in an expression.");
		      $attr_type = -2;
		  }
        else
            $attr_type = $x.attr_type;
    }
    ;

equality_expression  returns [int attr_type]
    : x = relational_expression (('==' | '!=') y = relational_expression)*   
    { if (($x.attr_type != $y.attr_type) &&  $y.attr_type!=-3 && $x.attr_type!=-3 &&  $x.attr_type!=-2 && $y.attr_type!=-2 && $y.attr_type!=0)  {
			  System.out.println("Error: " + 
				                 $x.start.getLine() +
						         ": Type mismatch for the comparison operator in an expression.");
		      $attr_type = -2;
		  }
        else
            $attr_type = $x.attr_type;
    }
    ;

relational_expression returns [int attr_type]
    : x = shift_expression (('<'|'>' | '<=' | '>=')y =shift_expression)*  
    { if (($x.attr_type != $y.attr_type) &&  $y.attr_type!=-3 && $x.attr_type!=-3 &&  $x.attr_type!=-2 && $y.attr_type!=-2 && $y.attr_type!=0) {
			  System.out.println("Error: " + 
				                 $x.start.getLine() +
						         ": Type mismatch for the comparison operator in an expression.");
		      $attr_type = -2;
		  }
        else
            $attr_type = $x.attr_type;
    }
    ;

shift_expression  returns [int attr_type]
    :x = additive_expression(('<<' | '>>') y = additive_expression)* 
    { if (($x.attr_type != $y.attr_type) &&  $y.attr_type!=-3 && $x.attr_type!=-3 &&  $x.attr_type!=-2 && $y.attr_type!=-2 && $y.attr_type!=0) {
			  System.out.println("Error: " + 
				                 $x.start.getLine() +
						         ": Type mismatch for the comparison operator in an expression.");
                                 

		      $attr_type = -2;
		  }
        else
            $attr_type = $x.attr_type;
    }
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
    | 'printf' OP_PARENTHESIS (STRING (COMMA primary_expression)*) CL_PARENTHESIS { if (TRACEON) System.out.println("print: " + $STRING.text );}
    ;

label_statement 
    : ID COLON statement { if(TRACEON) System.out.println("ID :"); }
    | CASE_TYPE conditional_expression COLON statement { if(TRACEON) System.out.println("type: case"); }
     { if(TRACEON) 
        System.out.println("type: while_TYPE");
      if($conditional_expression.attr_type == 0)
             System.out.println("Error: " + 
				                 $conditional_expression.start.getLine() +": Type of the expression isn't boolean");
        
        
     }
    | DEFAULT_TYPE COLON statement { if(TRACEON) System.out.println("type: default"); }
    ;

expression_statement  returns [int attr_type]
    : SEMICOLON   {$attr_type = -1;}
    | expression SEMICOLON   {$attr_type = $expression.attr_type;}
    ;
compound_statement
    : OP_CURLY_BRACKET  declarations statement_list? CL_CURLY_BRACKET { if(TRACEON) System.out.println("type: compound_statement"); }
    ;
statement_list
    : statement+
    ;
selection_statement 
    : IF_TYPE OP_PARENTHESIS expression CL_PARENTHESIS statement  (('else')=> 'else' statement)? 
    { if(TRACEON) System.out.println("type: IF_TYPE");
    if($expression.attr_type == 0)
            System.out.println("Error: " + 
				                 $expression.start.getLine() +": Type of the expression isn't boolean");
        
    
    ;}
    | SWITCH_TYPE OP_PARENTHESIS expression CL_PARENTHESIS statement { if(TRACEON) System.out.println("type: switch_TYPE"); }
     { if(TRACEON) 
        System.out.println("type: while_TYPE");
      if($expression.attr_type == 0)
             System.out.println("Error: " + 
				                 $expression.start.getLine() +": Type of the expression isn't boolean");
        
        
     }
    ;


jump_statement
    : GOTO_TYPE ID SEMICOLON  { if(TRACEON) System.out.println("type: goto_TYPE"); }
    | CONTINUE_TYPE SEMICOLON  { if(TRACEON) System.out.println("type: contiune_TYPE"); }
    | BREAK_TYPE SEMICOLON { if(TRACEON) System.out.println("type: break_TYPE"); }
    | RETURN_TYPE SEMICOLON { if(TRACEON) System.out.println("type: return_TYPE"); }
    | RETURN_TYPE expression SEMICOLON { if(TRACEON) System.out.println("type: return_expression_TYPE"); }
    ;
iteration_statement
    : WHILE_TYPE OP_PARENTHESIS expression CL_PARENTHESIS statement   
    { if(TRACEON) 
        System.out.println("type: while_TYPE");
      if($expression.attr_type == 0)
             System.out.println("Error: " + 
				                 $expression.start.getLine() +": Type of the expression isn't boolean");
        
        
     }
    | DO_TYPE statement WHILE_TYPE OP_PARENTHESIS expression CL_PARENTHESIS SEMICOLON  
    { if(TRACEON) System.out.println("type: do_while_TYPE");if($expression.attr_type == 0){
             System.out.println("Error: " + 
				                 $expression.start.getLine() +": Type of the expression isn't boolean");
        
    }}
    | FOR_TYPE OP_PARENTHESIS x = expression_statement y = expression_statement expression? CL_PARENTHESIS statement  
    { if(TRACEON) System.out.println("type: for_loop_TYPE");
    if($y.attr_type == 0){
            System.out.println("Error: " + 
				                 $y.start.getLine() +": Type of the expression isn't boolean");
        
        
    }}
    ;

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*---------------------------*/
/*          Keywords         */
/*---------------------------*/
AUTO_TYPE :'auto';
BOOL_TYPE :'bool';
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
BOOL1_TYPE :'_Bool';
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


















