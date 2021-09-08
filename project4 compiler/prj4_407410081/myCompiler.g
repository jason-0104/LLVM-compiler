grammar myCompiler;

options {
   language = Java;
}

@header {
    // import packages here.
    import java.util.HashMap;
    import java.util.ArrayList;
}

@members {
   boolean TRACEON =false;

   // Type information.
   public enum Type {
      ERR, BOOL, INT, FLOAT, CHAR, CONST_INT, CONST_FLOAT, ERR2, ERR3;
   }

   public enum REL_OPER {
      GT, GE, LT, LE, EQ, NE;
   }

   // This structure is used to record the information of a variable or a constant.
   class tVar {
      int   varIndex; // temporary variable's index. Ex: t1, t2, ..., etc.
      int   iValue;   // value of constant integer. Ex: 123.
      float fValue;   // value of constant floating point. Ex: 2.314.
   };

   class Info {
      Type the_Type;  // type information.
      tVar theVar;
	   
	   Info() {
         the_Type = Type.ERR;
		   theVar = new tVar();
	   }
   };

	
   // ============================================
   // Create a symbol table.
	// ArrayList is easy to extend to add more info. into symbol table.
	//
	// The structure of symbol table:
	// <variable ID, [Type, [varIndex or iValue, or fValue]]>
	//    - type: the variable type   (please check "enum Type")
	//    - varIndex: the variable's index, ex: t1, t2, ...
	//    - iValue: value of integer constant.
	//    - fValue: value of floating-point constant.
   // ============================================

   HashMap<String, Info> symtab = new HashMap<String, Info>();

   // labelCount is used to represent temporary label.
   // The first index is 0.
   int labelCount = 0;
   int conditionCount = 0;
   // varCount is used to represent temporary variables.
   // The first index is 0.
   int varCount = 0;
   
   int strvarcount = 0;
   // Record all assembly instructions.
   List<String> TextCode = new ArrayList<String>();


   /*
   * Output prologue.
   */
   void prologue() {
      TextCode.add("; === prologue ====");
      TextCode.add("declare dso_local i32 @printf(i8*, ...)");
      TextCode.add("define dso_local i32 @main()");
      TextCode.add("{");
   }
	
   /*
   * Output epilogue.
   */
   void epilogue() {
      /* handle epilogue */
      TextCode.add("\n; === epilogue ===");
	   TextCode.add("\tret i32 0");
      TextCode.add("}");
   }
   
   /* Generate a new label */
   String newLabel()
   {
      labelCount ++;
      return (new String("L")) + Integer.toString(labelCount);
   }

   public List<String> getTextCode()
   {
      return TextCode;
   }
}

program: (VOID|INT) MAIN '(' ')' {
      /* Output function prologue */
      prologue();
   }

   '{' declarations statements '}' {
      if (TRACEON)
         System.out.println("VOID MAIN () {declarations statements}");

      /* output function epilogue */	  
      epilogue();
   }
   ;


declarations: type Identifier ';' declarations {
      if (TRACEON)
         System.out.println("declarations: type Identifier : declarations");

      if (symtab.containsKey($Identifier.text)) {
         // variable re-declared.
         System.out.println("Type Error: " + 
                              $Identifier.getLine() + 
                           ": Redeclared identifier.");
         System.exit(0);
      }
            
      /* Add ID and its info into the symbol table. */
      Info the_entry = new Info();
      the_entry.the_Type = $type.attr_type;
      the_entry.theVar.varIndex = varCount;
      varCount ++;
      symtab.put($Identifier.text, the_entry);

      // issue the instruction.
      // Ex: \%a = alloca i32, align 4
      if ($type.attr_type == Type.INT) { 
         TextCode.add("\t\%t" + the_entry.theVar.varIndex + " = alloca i32, align 4");
      }
      else if ($type.attr_type == Type.FLOAT) { 
         TextCode.add("\t\%t" + the_entry.theVar.varIndex + " = alloca float, align 4" );
      }
      else if ($type.attr_type == Type.CHAR) { 
         TextCode.add("\t\%t" + the_entry.theVar.varIndex + " = alloca i8");
      }
   }
   | {
      if (TRACEON)
         System.out.println("declarations: ");
   }
   ;

type
returns [Type attr_type]
   : INT { if (TRACEON) System.out.println("type: INT"); $attr_type=Type.INT; }
   | CHAR { if (TRACEON) System.out.println("type: CHAR"); $attr_type=Type.CHAR; }
   | FLOAT {if (TRACEON) System.out.println("type: FLOAT"); $attr_type=Type.FLOAT; }
	;

statements
   : statement statements 
   |
   ;

statement
   : assign_stmt ';' 
   | if_stmt 
   | func_no_return_stmt ';' 
   | for_stmt 
   | print_stmt ';'
   ;
print_stmt
   :'printf' '('STRING_LITERAL (','x = argument)?')' 
   {
      if (TRACEON) System.out.println("printf");
      TextCode.add("\n");
      for (int i = TextCode.size()-1;i>0; i--) {
         if(TextCode.get(i).equals("define dso_local i32 @main()")){
            TextCode.set(i,TextCode.get(i-1));
            String a = $STRING_LITERAL.text;  
            String b = $x.text;     
            if(strvarcount==0){
               if($x.text==null){
                  if(a.substring(a.length()-3,a.length()-1).equals("\\n")){
                     int count = a.length()-2;
                     TextCode.set(i,"@.str. = private unnamed_addr constant ["+ count +" x i8]c"+a.substring(0,a.length()-3)+"\\0A\\00"+'"' + ", align 1");
                     TextCode.add("\t\%t" + varCount + " = call i32 (i8*,...)@printf(i8* getelementptr inbounds ([" + count + " x i8], [" + count + " x i8]* @.str.,i64 0, i64 0))");
                  }
                  
                  else{ 
                     int count = a.length()-1;
                     TextCode.set(i,"@.str. = private unnamed_addr constant ["+ count +" x i8]c"+a.substring(0,a.length()-1)+"\\00"+'"' + ", align 1");
                     TextCode.add("\t\%t" + varCount + " = call i32 (i8*,...)@printf(i8* getelementptr inbounds ([" + count + " x i8], [" + count + " x i8]* @.str.,i64 0, i64 0))");
                  } 
               }
               else{
                  if(a.substring(a.length()-3,a.length()-1).equals("\\n")){
                     int count = a.length()-2;
                     TextCode.set(i,"@.str. = private unnamed_addr constant ["+ count +" x i8]c"+a.substring(0,a.length()-3)+"\\0A\\00"+'"' + ", align 1");
                     String arg_list = "";
                     for (int j=0; j<$x.argu.size(); j++) {
                        if ($x.argu.get(j).the_Type == Type.INT) {
                           arg_list = arg_list.concat(", i32 \%t" + $x.argu.get(j).theVar.varIndex);
                        }
                        else if ($x.argu.get(j).the_Type == Type.FLOAT) {
                           arg_list = arg_list.concat(", double \%t" + $x.argu.get(j).theVar.varIndex);
                        }
                     }
                     TextCode.add("\t\%t" + varCount + " = call i32 (i8*,...)@printf(i8* getelementptr inbounds ([" + count + " x i8], [" + count + " x i8]* @.str.,i64 0, i64 0)" + arg_list + ")");
                    
                  }
                  else{
                     int count = a.length()-1;
                     TextCode.set(i,"@.str. = private unnamed_addr constant ["+ count +" x i8]c"+a.substring(0,a.length()-1)+"\\00"+'"' + ", align 1");
                     String arg_list = "";
                     for (int j=0; j<$x.argu.size(); j++) {
                        if ($x.argu.get(j).the_Type == Type.INT) {
                           arg_list = arg_list.concat(", i32 \%t" + $x.argu.get(j).theVar.varIndex);
                        }
                        else if ($x.argu.get(j).the_Type == Type.FLOAT) {
                           arg_list = arg_list.concat(", double \%t" + $x.argu.get(j).theVar.varIndex);
                        }
                     }
                     TextCode.add("\t\%t" + varCount + " = call i32 (i8*,...)@printf(i8* getelementptr inbounds ([" + count + " x i8], [" + count + " x i8]* @.str.,i64 0, i64 0)" + arg_list + ")");
                    
                  }        
               }
            }
            else{
               if(x==null){            
                  if(a.substring(a.length()-3,a.length()-1).equals("\\n")){
                     int count = a.length()-2;
                     TextCode.set(i,"@.str."+strvarcount+" = private unnamed_addr constant ["+ count +" x i8]c"+a.substring(0,a.length()-3)+"\\0A\\00"+'"' + ", align 1");
                     TextCode.add("\t\%t" + varCount + " = call i32 (i8*,...)@printf(i8* getelementptr inbounds ([" + count + " x i8], [" + count + " x i8]* @.str."+strvarcount+",i64 0, i64 0))");
                  }
                     
                  else{ 
                     int count = a.length()-1;
                     TextCode.set(i,"@.str."+strvarcount+" = private unnamed_addr constant ["+ count +" x i8]c"+a.substring(0,a.length()-1)+"\\00"+'"' + ", align 1");
                     TextCode.add("\t\%t" + varCount + " = call i32 (i8*,...)@printf(i8* getelementptr inbounds ([" + count + " x i8], [" + count + " x i8]* @.str."+strvarcount+",i64 0, i64 0))");
                  } 
               }
               else{
                  if(a.substring(a.length()-3,a.length()-1).equals("\\n")){
                     int count = a.length()-2;
                     TextCode.set(i,"@.str."+strvarcount+" = private unnamed_addr constant ["+ count +" x i8]c"+a.substring(0,a.length()-3)+"\\0A\\00"+'"' + ", align 1");
                     String arg_list = "";
                     for (int j=0; j<$x.argu.size(); j++) {
                        if ($x.argu.get(j).the_Type == Type.INT) {
                           arg_list = arg_list.concat(", i32 \%t" + $x.argu.get(j).theVar.varIndex);
                        }
                        else if ($x.argu.get(j).the_Type == Type.FLOAT) {
                           arg_list = arg_list.concat(", double \%t" + $x.argu.get(j).theVar.varIndex);
                        }
                     }
                     TextCode.add("\t\%t" + varCount + " = call i32 (i8*,...)@printf(i8* getelementptr inbounds ([" + count + " x i8], [" + count + " x i8]* @.str."+strvarcount+",i64 0, i64 0)" + arg_list + ")");
                     

                  }
                  else{ 
                     int count = a.length()-1;
                     TextCode.set(i,"@.str."+strvarcount+" = private unnamed_addr constant ["+ count +" x i8]c"+a.substring(0,a.length()-1)+"\\00"+'"' + ", align 1");
                     String arg_list = "";
                     for (int j=0; j<$x.argu.size(); j++) {
                        if ($x.argu.get(j).the_Type == Type.INT) {
                           arg_list = arg_list.concat(", i32 \%t" + $x.argu.get(j).theVar.varIndex);
                        }
                        else if ($x.argu.get(j).the_Type == Type.FLOAT) {
                           arg_list = arg_list.concat(", double \%t" + $x.argu.get(j).theVar.varIndex);
                        }
                     }
                     TextCode.add("\t\%t" + varCount + " = call i32 (i8*,...)@printf(i8* getelementptr inbounds ([" + count + " x i8], [" + count + " x i8]* @.str."+strvarcount+",i64 0, i64 0)" + arg_list + ")");

                  }
                  //System.out.println(var);
               }       
            }
         varCount++;
         strvarcount++; 
         break;
         }
         TextCode.set(i,TextCode.get(i-1));
      }
   }
   ;
for_stmt
   @init {String lab = newLabel();}
   : FOR '(' assign_stmt ';' 
   {
      String lloop = newLabel();
      TextCode.add("\tbr label \%" + lloop);
      TextCode.add("\n" + lloop + ":");
   }
   a=cond_expression 
   {
      TextCode.add("\tbr i1 \%cond" + conditionCount + ", label \%" + $a.ltrue + ", label \%" + $a.lfalse);
      TextCode.add("\n" + lab + ":");
      conditionCount++;
   }
   ';' assign_stmt
   {
       TextCode.add("\tbr label\%" + lloop );
       TextCode.add("\n" + $a.ltrue + ":");
   } 
   ')' 
   block_stmt 
   {
      TextCode.add("\tbr label \%" + lab);
      TextCode.add("\n" + $a.lfalse + ":");
   }
   ;
   
if_stmt
   : a=if_then_stmt if_else_stmt 
   {
      TextCode.add("\tbr label \%" + $a.lend);
      TextCode.add("\n" + $a.lend + ":");
   }
   ;
	   
if_then_stmt
returns [String lend]
   : IF '(' a=cond_expression 
   {
      TextCode.add("\tbr i1 \%cond" + conditionCount + ", label \%" + $a.ltrue + ", label \%" + $a.lfalse);
      TextCode.add("\n" + $a.ltrue + ":");
      conditionCount++;
   }
   ')' block_stmt 
   { 
      lend = newLabel();
      TextCode.add("\tbr label \%" + lend);
      TextCode.add("\n" + $a.lfalse + ":");
   }
   ;

if_else_stmt
   : ELSE (block_stmt  ){ if (TRACEON) System.out.println("ELSE block_stmt"); }
   |
   ;
				  
block_stmt: 
   '{' statements '}'
   ;

assign_stmt
returns [Info theRHS, Info theLHS]
   : Identifier '=' arith_expression {
      //Info theRHS = $arith_expression.theInfo;
      //Info theLHS = symtab.get($Identifier.text); 
      $theRHS = $arith_expression.theInfo;
      $theLHS = symtab.get($Identifier.text); 

      if (($theLHS.the_Type == Type.INT) &&
         ($theRHS.the_Type == Type.INT)) {
            
         // issue store insruction.
         // Ex: store i32 \%tx, i32* \%ty
         TextCode.add("\tstore i32 \%t" + $theRHS.theVar.varIndex + ", i32* \%t" + $theLHS.theVar.varIndex + ", align 4");
      }
      else if (($theLHS.the_Type == Type.INT) &&
            ($theRHS.the_Type == Type.CONST_INT)) {
         // issue store insruction.
         // Ex: store i32 value, i32* \%ty
         TextCode.add("\tstore i32 " + $theRHS.theVar.iValue + ", i32* \%t" + $theLHS.theVar.varIndex + ", align 4");				
      }
      else if (($theLHS.the_Type == Type.FLOAT) &&
            ($theRHS.the_Type == Type.FLOAT)) {
         TextCode.add("\tstore float \%t" + $theRHS.theVar.varIndex + ", float* \%t" + $theLHS.theVar.varIndex + ", align 4");			
      }
      else if (($theLHS.the_Type == Type.FLOAT) &&
            ($theRHS.the_Type == Type.CONST_FLOAT)) {
         double val2 = $theRHS.theVar.fValue;
         long ans2 = Double.doubleToLongBits(val2);
         //System.out.println(val2 + " in int bits: (HEX) " + Long.toHexString(ans2));
         TextCode.add("\tstore float 0x" +Long.toHexString(ans2) + ", float* \%t" + $theLHS.theVar.varIndex + ", align 4");				
      }
   }
   ;

func_no_return_stmt: 
   Identifier '(' argument ')'
   ;

argument
returns [List<Info> argu]
@init{$argu = new ArrayList<Info>();}
   : a=arg 
   {
      $argu.add($a.theInfo);
      if ($a.theInfo.the_Type == Type.FLOAT) 
      {
         TextCode.add("\t\%t" + varCount + " = fpext float \%t" + $a.theInfo.theVar.varIndex + " to double");
         $a.theInfo.theVar.varIndex = varCount;
         varCount++;
      }
   } 
   (',' b=arg 
   {
      $argu.add($b.theInfo);
      if ($b.theInfo.the_Type == Type.FLOAT) 
      {
         TextCode.add("\t\%t" + varCount + " = fpext float \%t" + $b.theInfo.theVar.varIndex + " to double");
         $b.theInfo.theVar.varIndex = varCount;
         varCount++;
      }
   } )* 
   ;

arg
returns [Info theInfo]
   : a=arith_expression { $theInfo = $a.theInfo;}
   ;
		   
cond_expression
returns [String ltrue, String lfalse]
   : a=arith_expression (relationop b=arith_expression)* { 
      if (TRACEON) {
         System.out.println("a=arith_expression (relationop b=arith_expression)*"); 
      }

      if ($relationop.r_type == REL_OPER.GT) {
         if (($a.theInfo.the_Type == Type.INT) && 
            ($b.theInfo.the_Type == Type.INT)) {
            TextCode.add("\t\%cond" + conditionCount + " = icmp sgt i32 \%t" + $a.theInfo.theVar.varIndex +
                         ", \%t" + $b.theInfo.theVar.varIndex);
         }
         else if (($a.theInfo.the_Type == Type.INT) &&
                  ($b.theInfo.the_Type == Type.CONST_INT)) {
            TextCode.add("\t\%cond" + conditionCount + " = icmp sgt i32 \%t" + $a.theInfo.theVar.varIndex +
                         ", " + $b.theInfo.theVar.iValue);
         }
         else if (($a.theInfo.the_Type == Type.CONST_INT) &&
                  ($b.theInfo.the_Type == Type.CONST_INT)) {
            TextCode.add("\t\%cond" + conditionCount + " = icmp sgt i32 " + $b.theInfo.theVar.iValue +
                         ", " + $b.theInfo.theVar.iValue);
         }
         else if (($a.theInfo.the_Type == Type.CONST_INT) &&
                  ($b.theInfo.the_Type == Type.INT)) {
            TextCode.add("\t\%cond" + conditionCount + " = icmp sgt i32 " + $a.theInfo.theVar.iValue +
                         ", \%t" + $b.theInfo.theVar.varIndex);
         }

         else if (($a.theInfo.the_Type == Type.FLOAT) && 
            ($b.theInfo.the_Type == Type.FLOAT)) {
            TextCode.add("\t\%cond" + conditionCount + " = fcmp ogt float \%t" + $a.theInfo.theVar.varIndex +
                         ", \%t" + $b.theInfo.theVar.varIndex);
         }
         else if (($a.theInfo.the_Type == Type.FLOAT) &&
                  ($b.theInfo.the_Type == Type.CONST_FLOAT)) {
            TextCode.add("\t\%cond" + conditionCount + " = fcmp ogt float \%t" + $a.theInfo.theVar.varIndex +
                         ", " + $b.theInfo.theVar.fValue);
         }
         else if (($a.theInfo.the_Type == Type.CONST_FLOAT) &&
                  ($b.theInfo.the_Type == Type.CONST_FLOAT)) {
            TextCode.add("\t\%cond" + conditionCount + " = fcmp ogt float " + $b.theInfo.theVar.fValue +
                         ", " + $b.theInfo.theVar.fValue);
         }
         else if (($a.theInfo.the_Type == Type.CONST_FLOAT) &&
                  ($b.theInfo.the_Type == Type.FLOAT)) {
            TextCode.add("\t\%cond" + conditionCount + " = fcmp ogt float " + $a.theInfo.theVar.fValue +
                         ", \%t" + $b.theInfo.theVar.varIndex);
         }
         else if (($a.theInfo.the_Type != $b.theInfo.the_Type) &&  $a.theInfo.the_Type!= Type.ERR3 && $b.theInfo.the_Type!= Type.ERR3 &&  $a.theInfo.the_Type!= Type.ERR2 && $b.theInfo.the_Type!= Type.ERR2) {
			  System.out.println("Error: " + 
				                 $a.start.getLine() +
						         ": Type mismatch for the arithmetic operator in an expression.");
		      $a.theInfo.the_Type = Type.ERR2;
	      }
      }
      else if ($relationop.r_type == REL_OPER.GE) {
         if (($a.theInfo.the_Type == Type.INT) && 
            ($b.theInfo.the_Type == Type.INT)) {
            TextCode.add("\t\%cond" + conditionCount + " = icmp sge i32 \%t" + $a.theInfo.theVar.varIndex +
                         ", \%t" + $b.theInfo.theVar.varIndex);
         }
         else if (($a.theInfo.the_Type == Type.INT) &&
                  ($b.theInfo.the_Type == Type.CONST_INT)) {
            TextCode.add("\t\%cond" + conditionCount + " = icmp sge i32 \%t" + $a.theInfo.theVar.varIndex +
                         ", " + $b.theInfo.theVar.iValue);
         }
         else if (($a.theInfo.the_Type == Type.CONST_INT) &&
                  ($b.theInfo.the_Type == Type.CONST_INT)) {
            TextCode.add("\t\%cond" + conditionCount + " = icmp sge i32 " + $b.theInfo.theVar.iValue +
                         ", " + $b.theInfo.theVar.iValue);
         }
         else if (($a.theInfo.the_Type == Type.CONST_INT) &&
                  ($b.theInfo.the_Type == Type.INT)) {
            TextCode.add("\t\%cond" + conditionCount + " = icmp sge i32 " + $a.theInfo.theVar.iValue +
                         ", \%t" + $b.theInfo.theVar.varIndex);
         }

         else if (($a.theInfo.the_Type == Type.FLOAT) && 
            ($b.theInfo.the_Type == Type.FLOAT)) {
            TextCode.add("\t\%cond" + conditionCount + " = fcmp oge float* \%t" + $a.theInfo.theVar.varIndex +
                         ", \%t" + $b.theInfo.theVar.varIndex);
         }
         else if (($a.theInfo.the_Type == Type.FLOAT) &&
                  ($b.theInfo.the_Type == Type.CONST_FLOAT)) {
            TextCode.add("\t\%cond" + conditionCount + " = fcmp oge float* \%t" + $a.theInfo.theVar.varIndex +
                         ", " + $b.theInfo.theVar.fValue);
         }
         else if (($a.theInfo.the_Type == Type.CONST_FLOAT) &&
                  ($b.theInfo.the_Type == Type.CONST_FLOAT)) {
            TextCode.add("\t\%cond" + conditionCount + " = fcmp oge float* " + $b.theInfo.theVar.fValue +
                         ", " + $b.theInfo.theVar.fValue);
         }
         else if (($a.theInfo.the_Type == Type.CONST_FLOAT) &&
                  ($b.theInfo.the_Type == Type.FLOAT)) {
            TextCode.add("\t\%cond" + conditionCount + " = fcmp oge float* " + $a.theInfo.theVar.fValue +
                         ", \%t" + $b.theInfo.theVar.varIndex);
         }
         else if (($a.theInfo.the_Type != $b.theInfo.the_Type) &&  $a.theInfo.the_Type!= Type.ERR3 && $b.theInfo.the_Type!= Type.ERR3 &&  $a.theInfo.the_Type!= Type.ERR2 && $b.theInfo.the_Type!= Type.ERR2) {
			  System.out.println("Error: " + 
				                 $a.start.getLine() +
						         ": Type mismatch for the arithmetic operator in an expression.");
		      $a.theInfo.the_Type = Type.ERR2;
	      }
      }
      else if ($relationop.r_type == REL_OPER.LT) {
         if (($a.theInfo.the_Type == Type.INT) && 
            ($b.theInfo.the_Type == Type.INT)) {
            TextCode.add("\t\%cond" + conditionCount + " = icmp slt i32 \%t" + $a.theInfo.theVar.varIndex +
                         ", \%t" + $b.theInfo.theVar.varIndex);
         }
         else if (($a.theInfo.the_Type == Type.INT) &&
                  ($b.theInfo.the_Type == Type.CONST_INT)) {
            TextCode.add("\t\%cond" + conditionCount + " = icmp slt i32 \%t" + $a.theInfo.theVar.varIndex +
                         ", " + $b.theInfo.theVar.iValue);
         }
         else if (($a.theInfo.the_Type == Type.CONST_INT) &&
                  ($b.theInfo.the_Type == Type.CONST_INT)) {
            TextCode.add("\t\%cond" + conditionCount + " = icmp slt i32 " + $b.theInfo.theVar.iValue +
                         ", " + $b.theInfo.theVar.iValue);
         }
         else if (($a.theInfo.the_Type == Type.CONST_INT) &&
                  ($b.theInfo.the_Type == Type.INT)) {
            TextCode.add("\t\%cond" + conditionCount + " = icmp slt i32 " + $a.theInfo.theVar.iValue +
                         ", \%t" + $b.theInfo.theVar.varIndex);
         }

         else if (($a.theInfo.the_Type == Type.FLOAT) && 
            ($b.theInfo.the_Type == Type.FLOAT)) {
            TextCode.add("\t\%cond" + conditionCount + " = fcmp olt float* \%t" + $a.theInfo.theVar.varIndex +
                         ", \%t" + $b.theInfo.theVar.varIndex);
         }
         else if (($a.theInfo.the_Type == Type.FLOAT) &&
                  ($b.theInfo.the_Type == Type.CONST_FLOAT)) {
            TextCode.add("\t\%cond" + conditionCount + " = fcmp olt float* \%t" + $a.theInfo.theVar.varIndex +
                         ", " + $b.theInfo.theVar.fValue);
         }
         else if (($a.theInfo.the_Type == Type.CONST_FLOAT) &&
                  ($b.theInfo.the_Type == Type.CONST_FLOAT)) {
            TextCode.add("\t\%cond" + conditionCount + " = fcmp olt float* " + $b.theInfo.theVar.fValue +
                         ", " + $b.theInfo.theVar.fValue);
         }
         else if (($a.theInfo.the_Type == Type.CONST_FLOAT) &&
                  ($b.theInfo.the_Type == Type.FLOAT)) {
            TextCode.add("\t\%cond" + conditionCount + " = fcmp olt float* " + $a.theInfo.theVar.fValue +
                         ", \%t" + $b.theInfo.theVar.varIndex);
         }
         else if (($a.theInfo.the_Type != $b.theInfo.the_Type) &&  $a.theInfo.the_Type!= Type.ERR3 && $b.theInfo.the_Type!= Type.ERR3 &&  $a.theInfo.the_Type!= Type.ERR2 && $b.theInfo.the_Type!= Type.ERR2) {
			  System.out.println("Error: " + 
				                 $a.start.getLine() +
						         ": Type mismatch for the arithmetic operator in an expression.");
		      $a.theInfo.the_Type = Type.ERR2;
	      }
      }
      else if ($relationop.r_type == REL_OPER.LE) {
         if (($a.theInfo.the_Type == Type.INT) && 
            ($b.theInfo.the_Type == Type.INT)) {
            TextCode.add("\t\%cond" + conditionCount + " = icmp sle i32 \%t" + $a.theInfo.theVar.varIndex +
                         ", \%t" + $b.theInfo.theVar.varIndex);
         }
         else if (($a.theInfo.the_Type == Type.INT) &&
                  ($b.theInfo.the_Type == Type.CONST_INT)) {
            TextCode.add("\t\%cond" + conditionCount + " = icmp sle i32 \%t" + $a.theInfo.theVar.varIndex +
                         ", " + $b.theInfo.theVar.iValue);
         }
         else if (($a.theInfo.the_Type == Type.CONST_INT) &&
                  ($b.theInfo.the_Type == Type.CONST_INT)) {
            TextCode.add("\t\%cond" + conditionCount + " = icmp sle i32 " + $b.theInfo.theVar.iValue +
                         ", " + $b.theInfo.theVar.iValue);
         }
         else if (($a.theInfo.the_Type == Type.CONST_INT) &&
                  ($b.theInfo.the_Type == Type.INT)) {
            TextCode.add("\t\%cond" + conditionCount + " = icmp sle i32 " + $a.theInfo.theVar.iValue +
                         ", \%t" + $b.theInfo.theVar.varIndex);
         }

         else if (($a.theInfo.the_Type == Type.FLOAT) && 
            ($b.theInfo.the_Type == Type.FLOAT)) {
            TextCode.add("\t\%cond" + conditionCount + " = fcmp ole float* \%t" + $a.theInfo.theVar.varIndex +
                         ", \%t" + $b.theInfo.theVar.varIndex);
         }
         else if (($a.theInfo.the_Type == Type.FLOAT) &&
                  ($b.theInfo.the_Type == Type.CONST_FLOAT)) {
            TextCode.add("\t\%cond" + conditionCount + " = fcmp ole float* \%t" + $a.theInfo.theVar.varIndex +
                         ", " + $b.theInfo.theVar.fValue);
         }
         else if (($a.theInfo.the_Type == Type.CONST_FLOAT) &&
                  ($b.theInfo.the_Type == Type.CONST_FLOAT)) {
            TextCode.add("\t\%cond" + conditionCount + " = fcmp ole float* " + $b.theInfo.theVar.fValue +
                         ", " + $b.theInfo.theVar.fValue);
         }
         else if (($a.theInfo.the_Type == Type.CONST_FLOAT) &&
                  ($b.theInfo.the_Type == Type.FLOAT)) {
            TextCode.add("\t\%cond" + conditionCount + " = fcmp ole float* " + $a.theInfo.theVar.fValue +
                         ", \%t" + $b.theInfo.theVar.varIndex);
         }
         else if (($a.theInfo.the_Type != $b.theInfo.the_Type) &&  $a.theInfo.the_Type!= Type.ERR3 && $b.theInfo.the_Type!= Type.ERR3 &&  $a.theInfo.the_Type!= Type.ERR2 && $b.theInfo.the_Type!= Type.ERR2) {
			  System.out.println("Error: " + 
				                 $a.start.getLine() +
						         ": Type mismatch for the arithmetic operator in an expression.");
		      $a.theInfo.the_Type = Type.ERR2;
	      }
      }
      else if ($relationop.r_type == REL_OPER.EQ) {
         if (($a.theInfo.the_Type == Type.INT) && 
            ($b.theInfo.the_Type == Type.INT)) {
            TextCode.add("\t\%cond" + conditionCount + " = icmp eq i32 \%t" + $a.theInfo.theVar.varIndex +
                         ", \%t" + $b.theInfo.theVar.varIndex);
         }
         else if (($a.theInfo.the_Type == Type.INT) &&
                  ($b.theInfo.the_Type == Type.CONST_INT)) {
            TextCode.add("\t\%cond" + conditionCount + " = icmp eq i32 \%t" + $a.theInfo.theVar.varIndex +
                         ", " + $b.theInfo.theVar.iValue);
         }
         else if (($a.theInfo.the_Type == Type.CONST_INT) &&
                  ($b.theInfo.the_Type == Type.CONST_INT)) {
            TextCode.add("\t\%cond" + conditionCount + " = icmp eq i32 " + $b.theInfo.theVar.iValue +
                         ", " + $b.theInfo.theVar.iValue);
         }
         else if (($a.theInfo.the_Type == Type.CONST_INT) &&
                  ($b.theInfo.the_Type == Type.INT)) {
            TextCode.add("\t\%cond" + conditionCount + " = icmp eq i32 " + $a.theInfo.theVar.iValue +
                         ", \%t" + $b.theInfo.theVar.varIndex);
         }

         else if (($a.theInfo.the_Type == Type.FLOAT) && 
            ($b.theInfo.the_Type == Type.FLOAT)) {
            TextCode.add("\t\%cond" + conditionCount + " = fcmp oeq float* \%t" + $a.theInfo.theVar.varIndex +
                         ", \%t" + $b.theInfo.theVar.varIndex);
         }
         else if (($a.theInfo.the_Type == Type.FLOAT) &&
                  ($b.theInfo.the_Type == Type.CONST_FLOAT)) {
            TextCode.add("\t\%cond" + conditionCount + " = fcmp oeq float* \%t" + $a.theInfo.theVar.varIndex +
                         ", " + $b.theInfo.theVar.fValue);
         }
         else if (($a.theInfo.the_Type == Type.CONST_FLOAT) &&
                  ($b.theInfo.the_Type == Type.CONST_FLOAT)) {
            TextCode.add("\t\%cond" + conditionCount + " = fcmp oeq float* " + $b.theInfo.theVar.fValue +
                         ", " + $b.theInfo.theVar.fValue);
         }
         else if (($a.theInfo.the_Type == Type.CONST_FLOAT) &&
                  ($b.theInfo.the_Type == Type.FLOAT)) {
            TextCode.add("\t\%cond" + conditionCount + " = fcmp oeq float* " + $a.theInfo.theVar.fValue +
                         ", \%t" + $b.theInfo.theVar.varIndex);
         }
         else if (($a.theInfo.the_Type != $b.theInfo.the_Type) &&  $a.theInfo.the_Type!= Type.ERR3 && $b.theInfo.the_Type!= Type.ERR3 &&  $a.theInfo.the_Type!= Type.ERR2 && $b.theInfo.the_Type!= Type.ERR2) {
			  System.out.println("Error: " + 
				                 $a.start.getLine() +
						         ": Type mismatch for the arithmetic operator in an expression.");
		      $a.theInfo.the_Type = Type.ERR2;
	      }
      }
      else if ($relationop.r_type == REL_OPER.NE) {
         if (($a.theInfo.the_Type == Type.INT) && 
            ($b.theInfo.the_Type == Type.INT)) {
            TextCode.add("\t\%cond" + conditionCount + " = icmp ne i32 \%t" + $a.theInfo.theVar.varIndex +
                         ", \%t" + $b.theInfo.theVar.varIndex);
         }
         else if (($a.theInfo.the_Type == Type.INT) &&
                  ($b.theInfo.the_Type == Type.CONST_INT)) {
            TextCode.add("\t\%cond" + conditionCount + " = icmp ne i32 \%t" + $a.theInfo.theVar.varIndex +
                         ", " + $b.theInfo.theVar.iValue);
         }
         else if (($a.theInfo.the_Type == Type.CONST_INT) &&
                  ($b.theInfo.the_Type == Type.CONST_INT)) {
            TextCode.add("\t\%cond" + conditionCount + " = icmp ne i32 " + $b.theInfo.theVar.iValue +
                         ", " + $b.theInfo.theVar.iValue);
         }
         else if (($a.theInfo.the_Type == Type.CONST_INT) &&
                  ($b.theInfo.the_Type == Type.INT)) {
            TextCode.add("\t\%cond" + conditionCount + " = icmp ne i32 " + $a.theInfo.theVar.iValue +
                         ", \%t" + $b.theInfo.theVar.varIndex);
         }

         else if (($a.theInfo.the_Type == Type.FLOAT) && 
            ($b.theInfo.the_Type == Type.FLOAT)) {
            TextCode.add("\t\%cond" + conditionCount + " = fcmp one float* \%t" + $a.theInfo.theVar.varIndex +
                         ", \%t" + $b.theInfo.theVar.varIndex);
         }
         else if (($a.theInfo.the_Type == Type.FLOAT) &&
                  ($b.theInfo.the_Type == Type.CONST_FLOAT)) {
            TextCode.add("\t\%cond" + conditionCount + " = fcmp one float* \%t" + $a.theInfo.theVar.varIndex +
                         ", " + $b.theInfo.theVar.fValue);
         }
         else if (($a.theInfo.the_Type == Type.CONST_FLOAT) &&
                  ($b.theInfo.the_Type == Type.CONST_FLOAT)) {
            TextCode.add("\t\%cond" + conditionCount + " = fcmp one float* " + $b.theInfo.theVar.fValue +
                         ", " + $b.theInfo.theVar.fValue);
         }
         else if (($a.theInfo.the_Type == Type.CONST_FLOAT) &&
                  ($b.theInfo.the_Type == Type.FLOAT)) {
            TextCode.add("\t\%cond" + conditionCount + " = fcmp one float* " + $a.theInfo.theVar.fValue +
                         ", \%t" + $b.theInfo.theVar.varIndex);
         }
         else if (($a.theInfo.the_Type != $b.theInfo.the_Type) &&  $a.theInfo.the_Type!= Type.ERR3 && $b.theInfo.the_Type!= Type.ERR3 &&  $a.theInfo.the_Type!= Type.ERR2 && $b.theInfo.the_Type!= Type.ERR2) {
			  System.out.println("Error: " + 
				                 $a.start.getLine() +
						         ": Type mismatch for the arithmetic operator in an expression.");
		      $a.theInfo.the_Type = Type.ERR2;
	      }
      }
      else {
         System.out.println("Error: " + $a.start.getLine() + ": Not the conditional expression.");
      }
      $ltrue = newLabel();
      $lfalse = newLabel();
   }
   ;


relationop
returns [REL_OPER r_type]
   : '>' 
   { 
      if (TRACEON) System.out.println("Relation operator: >");
      $r_type = REL_OPER.GT; 
   }
   | '>=' 
   { 
      if (TRACEON) System.out.println("Relation operator: >=");
      $r_type = REL_OPER.GE; 
   }
   | '<' 
   { 
      if (TRACEON) System.out.println("Relation operator: <");
      $r_type = REL_OPER.LT; 
   }
   | '<=' 
   { 
      if (TRACEON) System.out.println("Relation operator: <=");
      $r_type = REL_OPER.LE; 
   }
   | '==' 
   { 
      if (TRACEON) System.out.println("Relation operator: ==");
      $r_type = REL_OPER.EQ; 
   }
   | '!=' 
   { 
      if (TRACEON) System.out.println("Relation operator: !=");
      $r_type = REL_OPER.NE; 
   }
   ;
	
	   
arith_expression
returns [Info theInfo]
@init {$theInfo = new Info();}
   : a=multExpr { $theInfo = $a.theInfo; }
   ( '+' b=multExpr 
   {
   
      // We need to do type checking first.
      // ...

      // code generation.					   
      if (($a.theInfo.the_Type == Type.INT) && 
         ($b.theInfo.the_Type == Type.INT)) {
         TextCode.add("\t\%t" + varCount + " = add nsw i32 \%t" + 
               $theInfo.theVar.varIndex + ", \%t" + $b.theInfo.theVar.varIndex);

         $theInfo.the_Type = Type.INT;
         $theInfo.theVar.varIndex = varCount;
         varCount ++;
      }
      else if (($a.theInfo.the_Type == Type.INT) &&
         ($b.theInfo.the_Type == Type.CONST_INT)) {
         TextCode.add("\t\%t" + varCount + " = add nsw i32 \%t" + 
               $theInfo.theVar.varIndex + ", " + $b.theInfo.theVar.iValue);
         $theInfo.the_Type = Type.INT;
         $theInfo.theVar.varIndex = varCount;
         varCount ++;
      }
      else if (($a.theInfo.the_Type == Type.CONST_INT) &&
         ($b.theInfo.the_Type == Type.CONST_INT)) {
         TextCode.add("\t\%t" + varCount + " = add nsw i32 " + 
               $theInfo.theVar.iValue + ", " + $b.theInfo.theVar.iValue);

         $theInfo.the_Type = Type.INT;
         $theInfo.theVar.varIndex = varCount;
         varCount ++;
      }
      else if (($a.theInfo.the_Type == Type.CONST_INT) &&
         ($b.theInfo.the_Type == Type.INT)) {
         TextCode.add("\t\%t" + varCount + " = add nsw i32 " + 
               $theInfo.theVar.iValue + ", \%t" + $b.theInfo.theVar.varIndex);

         $theInfo.the_Type = Type.INT;
         $theInfo.theVar.varIndex = varCount;
         varCount ++;
      }

      else if (($a.theInfo.the_Type == Type.FLOAT) &&
         ($b.theInfo.the_Type == Type.FLOAT)) {
         
         TextCode.add("\t\%t" + varCount + " = fadd float \%t" + $theInfo.theVar.varIndex + ", \%t" + $b.theInfo.theVar.varIndex);

         $theInfo.the_Type = Type.FLOAT;
         $theInfo.theVar.varIndex = varCount;
         varCount ++;
      }
      else if (($a.theInfo.the_Type == Type.FLOAT) &&
         ($b.theInfo.the_Type == Type.CONST_FLOAT)) {
         double val2 =  $b.theInfo.theVar.fValue;
         long ans2 = Double.doubleToLongBits(val2);
         TextCode.add("\t\%t" + varCount + " = fadd float \%t" + $theInfo.theVar.varIndex + ", 0x" + Long.toHexString(ans2));

         $theInfo.the_Type = Type.FLOAT;
         $theInfo.theVar.varIndex = varCount;
         varCount ++;
      }
      else if (($a.theInfo.the_Type == Type.CONST_FLOAT) &&
         ($b.theInfo.the_Type == Type.CONST_FLOAT)) {
         double val2 =  $theInfo.theVar.fValue;
         long ans2 = Double.doubleToLongBits(val2);
         double val1 =  $b.theInfo.theVar.fValue;
         long ans1 = Double.doubleToLongBits(val1);
         TextCode.add("\t\%t" + varCount + " = fadd float 0x" + Long.toHexString(ans2) + ", 0x" + Long.toHexString(ans1));

         $theInfo.the_Type = Type.FLOAT;
         $theInfo.theVar.varIndex = varCount;
         varCount ++;
      }
      else if (($a.theInfo.the_Type == Type.CONST_FLOAT) &&
         ($b.theInfo.the_Type == Type.FLOAT)) {
         double val1 =  $theInfo.theVar.fValue;
         long ans1 = Double.doubleToLongBits(val1);
         TextCode.add("\t\%t" + varCount + " = fadd float 0x" +Long.toHexString(ans1) + ", \%t" + $b.theInfo.theVar.varIndex);

         $theInfo.the_Type = Type.FLOAT;
         $theInfo.theVar.varIndex = varCount;
         varCount ++;
      }
      else if (($a.theInfo.the_Type != $b.theInfo.the_Type) &&  $a.theInfo.the_Type!= Type.ERR3 && $b.theInfo.the_Type!= Type.ERR3 &&  $a.theInfo.the_Type!= Type.ERR2 && $b.theInfo.the_Type!= Type.ERR2) {
			  System.out.println("Error: " + 
				                 $a.start.getLine() +
						         ": Type mismatch for the arithmetic operator in an expression.");
		      $a.theInfo.the_Type = Type.ERR2;
	  }
    
   }
   | '-' c=multExpr {	   
      if (($a.theInfo.the_Type == Type.INT) &&
         ($c.theInfo.the_Type == Type.INT)) {
         TextCode.add("\t\%t" + varCount + " = sub i32 \%t" + $theInfo.theVar.varIndex + ", \%t" + $c.theInfo.theVar.varIndex);

         // Update arith_expression's theInfo.
         $theInfo.the_Type = Type.INT;
         $theInfo.theVar.varIndex = varCount;
         varCount ++;
      }
      else if (($a.theInfo.the_Type == Type.INT) &&
         ($c.theInfo.the_Type == Type.CONST_INT)) {
         TextCode.add("\t\%t" + varCount + " = sub i32 \%t" + $theInfo.theVar.varIndex + ", " + $c.theInfo.theVar.iValue);

         // Update arith_expression's theInfo.
         $theInfo.the_Type = Type.INT;
         $theInfo.theVar.varIndex = varCount;
         varCount ++;
      }
      else if (($a.theInfo.the_Type == Type.CONST_INT) &&
         ($c.theInfo.the_Type == Type.CONST_INT)) {
         TextCode.add("\t\%t" + varCount + " = sub i32 " + $theInfo.theVar.iValue + ", " + $c.theInfo.theVar.iValue);

         $theInfo.the_Type = Type.INT;
         $theInfo.theVar.varIndex = varCount;
         varCount ++;
      }
      else if (($a.theInfo.the_Type == Type.CONST_INT) &&
         ($c.theInfo.the_Type == Type.INT)) {
         TextCode.add("\t\%t" + varCount + " = sub i32 " + $theInfo.theVar.iValue + ", \%t" + $c.theInfo.theVar.varIndex);

         $theInfo.the_Type = Type.INT;
         $theInfo.theVar.varIndex = varCount;
         varCount ++;
      }
      else if (($a.theInfo.the_Type == Type.FLOAT) &&
         ($c.theInfo.the_Type == Type.FLOAT)) {
         TextCode.add("\t\%t" + varCount + " = fsub float \%t" + $theInfo.theVar.varIndex + ", \%t" + $c.theInfo.theVar.varIndex);

         // Update arith_expression's theInfo.
         $theInfo.the_Type = Type.FLOAT;
         $theInfo.theVar.varIndex = varCount;
         varCount ++;
      }
      else if (($a.theInfo.the_Type == Type.FLOAT) &&
         ($c.theInfo.the_Type == Type.CONST_FLOAT)) {
         double val2 =  $c.theInfo.theVar.fValue;
         long ans2 = Double.doubleToLongBits(val2);
         TextCode.add("\t\%t" + varCount + " = fsub float \%t" + $theInfo.theVar.varIndex + ", 0x" + Long.toHexString(ans2));

         // Update arith_expression's theInfo.
         $theInfo.the_Type = Type.FLOAT;
         $theInfo.theVar.varIndex = varCount;
         varCount ++;
      }
      else if (($a.theInfo.the_Type == Type.CONST_FLOAT) &&
         ($c.theInfo.the_Type == Type.CONST_FLOAT)) {
         double val2 =  $theInfo.theVar.fValue;
         long ans2 = Double.doubleToLongBits(val2);
         double val1 =  $c.theInfo.theVar.fValue;
         long ans1 = Double.doubleToLongBits(val1);
         TextCode.add("\t\%t" + varCount + " = fsub float 0x" + Long.toHexString(ans2) + ", 0x" + Long.toHexString(ans1));

         $theInfo.the_Type = Type.FLOAT;
         $theInfo.theVar.varIndex = varCount;
         varCount ++;
      }
      else if (($a.theInfo.the_Type == Type.CONST_FLOAT) &&
         ($c.theInfo.the_Type == Type.FLOAT)) {
         double val1 =  $theInfo.theVar.fValue;
         long ans1 = Double.doubleToLongBits(val1);
         TextCode.add("\t\%t" + varCount + " = fsub float 0x" +Long.toHexString(ans1) + ", \%t" + $c.theInfo.theVar.varIndex);

         $theInfo.the_Type = Type.FLOAT;
         $theInfo.theVar.varIndex = varCount;
         varCount ++;
      }
      else if (($a.theInfo.the_Type != $c.theInfo.the_Type) &&  $a.theInfo.the_Type!= Type.ERR3 && $c.theInfo.the_Type!= Type.ERR3 &&  $a.theInfo.the_Type!= Type.ERR2 && $c.theInfo.the_Type!= Type.ERR2) {
			  System.out.println("Error: " + 
				                 $a.start.getLine() +
						         ": Type mismatch for the arithmetic operator in an expression.");
		      $a.theInfo.the_Type = Type.ERR2;
	  }
   }
   )*
   ;

multExpr
returns [Info theInfo]
@init {$theInfo = new Info();}
   : a=signExpr { $theInfo=$a.theInfo; }
   ( '*' b=signExpr {
      if (($a.theInfo.the_Type == Type.INT) &&
         ($b.theInfo.the_Type == Type.INT)) {
         TextCode.add("\t\%t" + varCount + " = mul nsw i32 \%t" + $theInfo.theVar.varIndex + ", \%t" + $b.theInfo.theVar.varIndex);

         $theInfo.the_Type = Type.INT;
         $theInfo.theVar.varIndex = varCount;
         varCount ++;
      }
      else if (($a.theInfo.the_Type == Type.INT) &&
         ($b.theInfo.the_Type == Type.CONST_INT)) {
         TextCode.add("\t\%t" + varCount + " = mul nsw i32 \%t" + $theInfo.theVar.varIndex + ", " + $b.theInfo.theVar.iValue);

         $theInfo.the_Type = Type.INT;
         $theInfo.theVar.varIndex = varCount;
         varCount ++;
      }
      else if (($a.theInfo.the_Type == Type.CONST_INT) &&
         ($b.theInfo.the_Type == Type.CONST_INT)) {
         TextCode.add("\t\%t" + varCount + " = mul nsw i32 " + $theInfo.theVar.iValue + ", " + $b.theInfo.theVar.iValue);

         $theInfo.the_Type = Type.INT;
         $theInfo.theVar.varIndex = varCount;
         varCount ++;
      }
      else if (($a.theInfo.the_Type == Type.CONST_INT) &&
         ($b.theInfo.the_Type == Type.INT)) {
         TextCode.add("\t\%t" + varCount + " = mul nsw i32 " + $theInfo.theVar.iValue + ", \%t" + $b.theInfo.theVar.varIndex);

         $theInfo.the_Type = Type.INT;
         $theInfo.theVar.varIndex = varCount;
         varCount ++;
      }
      else if (($a.theInfo.the_Type == Type.FLOAT) &&
         ($b.theInfo.the_Type == Type.FLOAT)) {
         TextCode.add("\t\%t" + varCount + " = fmul float \%t" + $theInfo.theVar.varIndex + ", \%t" + $b.theInfo.theVar.varIndex);

         $theInfo.the_Type = Type.FLOAT;
         $theInfo.theVar.varIndex = varCount;
         varCount ++;
      }
      else if (($a.theInfo.the_Type == Type.FLOAT) &&
         ($b.theInfo.the_Type == Type.CONST_FLOAT)) {
         double val2 =  $b.theInfo.theVar.fValue;
         long ans2 = Double.doubleToLongBits(val2);
         TextCode.add("\t\%t" + varCount + " = fmul float \%t" + $theInfo.theVar.varIndex + ", 0x" + Long.toHexString(ans2));

         // Update arith_expression's theInfo.
         $theInfo.the_Type = Type.FLOAT;
         $theInfo.theVar.varIndex = varCount;
         varCount ++;
      }
      else if (($a.theInfo.the_Type == Type.CONST_FLOAT) &&
         ($b.theInfo.the_Type == Type.CONST_FLOAT)) {
         double val2 =  $theInfo.theVar.fValue;
         long ans2 = Double.doubleToLongBits(val2);
         double val1 =  $b.theInfo.theVar.fValue;
         long ans1 = Double.doubleToLongBits(val1);
         TextCode.add("\t\%t" + varCount + " = fmul float 0x" + Long.toHexString(ans2) + ", 0x" + Long.toHexString(ans1));

         $theInfo.the_Type = Type.FLOAT;
         $theInfo.theVar.varIndex = varCount;
         varCount ++;
      }
      else if (($a.theInfo.the_Type == Type.CONST_FLOAT) &&
         ($b.theInfo.the_Type == Type.FLOAT)) {
         double val1 =  $theInfo.theVar.fValue;
         long ans1 = Double.doubleToLongBits(val1);
         TextCode.add("\t\%t" + varCount + " = fmul float 0x" +Long.toHexString(ans1) + ", \%t" + $b.theInfo.theVar.varIndex);

         $theInfo.the_Type = Type.FLOAT;
         $theInfo.theVar.varIndex = varCount;
         varCount ++;
      }
       else if (($a.theInfo.the_Type != $b.theInfo.the_Type) &&  $a.theInfo.the_Type!= Type.ERR3 && $b.theInfo.the_Type!= Type.ERR3 &&  $a.theInfo.the_Type!= Type.ERR2 && $b.theInfo.the_Type!= Type.ERR2) {
			  System.out.println("Error: " + 
				                 $a.start.getLine() +
						         ": Type mismatch for the arithmetic operator in an expression.");
		      $a.theInfo.the_Type = Type.ERR2;
	  }
   }
   | '/' c=signExpr {
      if (($a.theInfo.the_Type == Type.INT) &&
         ($c.theInfo.the_Type == Type.INT)) {
         TextCode.add("\t\%t" + varCount + " = sdiv i32 \%t" + $theInfo.theVar.varIndex + ", \%t" + $c.theInfo.theVar.varIndex);

         $theInfo.the_Type = Type.INT;
         $theInfo.theVar.varIndex = varCount;
         varCount ++;
      }
      else if (($a.theInfo.the_Type == Type.INT) &&
         ($c.theInfo.the_Type == Type.CONST_INT)) {
         TextCode.add("\t\%t" + varCount + " = sdiv i32 \%t" + $theInfo.theVar.varIndex + ", " + $c.theInfo.theVar.iValue);

         $theInfo.the_Type = Type.INT;
         $theInfo.theVar.varIndex = varCount;
         varCount ++;
      }
      else if (($a.theInfo.the_Type == Type.CONST_INT) &&
         ($c.theInfo.the_Type == Type.CONST_INT)) {
         TextCode.add("\t\%t" + varCount + " = sdiv i32 " + $theInfo.theVar.iValue + ", " + $c.theInfo.theVar.iValue);

         $theInfo.the_Type = Type.INT;
         $theInfo.theVar.varIndex = varCount;
         varCount ++;
      }
      else if (($a.theInfo.the_Type == Type.CONST_INT) &&
         ($c.theInfo.the_Type == Type.INT)) {
         TextCode.add("\t\%t" + varCount + " = sdiv i32 " + $theInfo.theVar.iValue + ", \%t" + $c.theInfo.theVar.varIndex);

         $theInfo.the_Type = Type.INT;
         $theInfo.theVar.varIndex = varCount;
         varCount ++;
      }

      else if (($a.theInfo.the_Type == Type.FLOAT) &&
         ($c.theInfo.the_Type == Type.FLOAT)) {
         TextCode.add("\t\%t" + varCount + " = fdiv float \%t" + $theInfo.theVar.varIndex + ", \%t" + $c.theInfo.theVar.varIndex);

         $theInfo.the_Type = Type.FLOAT;
         $theInfo.theVar.varIndex = varCount;
         varCount ++;
      }
      else if (($a.theInfo.the_Type == Type.FLOAT) &&
         ($b.theInfo.the_Type == Type.CONST_FLOAT)) {
         double val2 =  $b.theInfo.theVar.fValue;
         long ans2 = Double.doubleToLongBits(val2);
         TextCode.add("\t\%t" + varCount + " = fdiv float \%t" + $theInfo.theVar.varIndex + ", 0x" + Long.toHexString(ans2));

         // Update arith_expression's theInfo.
         $theInfo.the_Type = Type.FLOAT;
         $theInfo.theVar.varIndex = varCount;
         varCount ++;
      }
      else if (($a.theInfo.the_Type == Type.CONST_FLOAT) &&
         ($c.theInfo.the_Type == Type.CONST_FLOAT)) {
         double val2 =  $theInfo.theVar.fValue;
         long ans2 = Double.doubleToLongBits(val2);
         double val1 =  $c.theInfo.theVar.fValue;
         long ans1 = Double.doubleToLongBits(val1);
         TextCode.add("\t\%t" + varCount + " = fdiv float 0x" + Long.toHexString(ans2) + ", 0x" + Long.toHexString(ans1));

         $theInfo.the_Type = Type.FLOAT;
         $theInfo.theVar.varIndex = varCount;
         varCount ++;
      }
      else if (($a.theInfo.the_Type == Type.CONST_FLOAT) &&
         ($c.theInfo.the_Type == Type.FLOAT)) {
         double val1 =  $theInfo.theVar.fValue;
         long ans1 = Double.doubleToLongBits(val1);
         TextCode.add("\t\%t" + varCount + " = fdiv float 0x" +Long.toHexString(ans1) + ", \%t" + $c.theInfo.theVar.varIndex);

         $theInfo.the_Type = Type.FLOAT;
         $theInfo.theVar.varIndex = varCount;
         varCount ++;
      }
      else if (($a.theInfo.the_Type != $c.theInfo.the_Type) &&  $a.theInfo.the_Type!= Type.ERR3 && $c.theInfo.the_Type!= Type.ERR3 &&  $a.theInfo.the_Type!= Type.ERR2 && $c.theInfo.the_Type!= Type.ERR2) {
			  System.out.println("Error: " + 
				                 $a.start.getLine() +
						         ": Type mismatch for the arithmetic operator in an expression.");
		      $a.theInfo.the_Type = Type.ERR2;
	  }
   }
   |'%'
    d=signExpr {
      if (($a.theInfo.the_Type == Type.INT) &&
         ($d.theInfo.the_Type == Type.INT)) {
         TextCode.add("\t\%t" + varCount + " = srem i32 \%t" + $theInfo.theVar.varIndex + ", \%t" + $d.theInfo.theVar.varIndex);

         $theInfo.the_Type = Type.INT;
         $theInfo.theVar.varIndex = varCount;
         varCount ++;
      }
      else if (($a.theInfo.the_Type == Type.INT) &&
         ($d.theInfo.the_Type == Type.CONST_INT)) {
         TextCode.add("\t\%t" + varCount + " = srem i32 \%t" + $theInfo.theVar.varIndex + ", " + $d.theInfo.theVar.iValue);

         $theInfo.the_Type = Type.INT;
         $theInfo.theVar.varIndex = varCount;
         varCount ++;
      }
      else if (($a.theInfo.the_Type == Type.CONST_INT) &&
         ($d.theInfo.the_Type == Type.CONST_INT)) {
         TextCode.add("\t\%t" + varCount + " = srem i32 " + $theInfo.theVar.iValue + ", " + $d.theInfo.theVar.iValue);

         $theInfo.the_Type = Type.INT;
         $theInfo.theVar.varIndex = varCount;
         varCount ++;
      }
      else if (($a.theInfo.the_Type == Type.CONST_INT) &&
         ($d.theInfo.the_Type == Type.INT)) {
         TextCode.add("\t\%t" + varCount + " = srem i32 " + $theInfo.theVar.iValue + ", \%t" + $d.theInfo.theVar.varIndex);

         $theInfo.the_Type = Type.INT;
         $theInfo.theVar.varIndex = varCount;
         varCount ++;
      }

      else if (($a.theInfo.the_Type == Type.FLOAT) &&
         ($d.theInfo.the_Type == Type.FLOAT)) {
         TextCode.add("\t\%t" + varCount + " = frem float \%t" + $theInfo.theVar.varIndex + ", \%t" + $d.theInfo.theVar.varIndex);

         $theInfo.the_Type = Type.FLOAT;
         $theInfo.theVar.varIndex = varCount;
         varCount ++;
      }
      else if (($a.theInfo.the_Type == Type.FLOAT) &&
         ($d.theInfo.the_Type == Type.CONST_FLOAT)) {
         double val2 =  $d.theInfo.theVar.fValue;
         long ans2 = Double.doubleToLongBits(val2);
         TextCode.add("\t\%t" + varCount + " = frem float \%t" + $theInfo.theVar.varIndex + ", 0x" + Long.toHexString(ans2));

         // Update arith_expression's theInfo.
         $theInfo.the_Type = Type.FLOAT;
         $theInfo.theVar.varIndex = varCount;
         varCount ++;
      }
      else if (($a.theInfo.the_Type == Type.CONST_FLOAT) &&
         ($d.theInfo.the_Type == Type.CONST_FLOAT)) {
         double val2 =  $theInfo.theVar.fValue;
         long ans2 = Double.doubleToLongBits(val2);
         double val1 =  $d.theInfo.theVar.fValue;
         long ans1 = Double.doubleToLongBits(val1);
         TextCode.add("\t\%t" + varCount + " = frem float 0x" + Long.toHexString(ans2) + ", 0x" + Long.toHexString(ans1));

         $theInfo.the_Type = Type.FLOAT;
         $theInfo.theVar.varIndex = varCount;
         varCount ++;
      }
      else if (($a.theInfo.the_Type == Type.CONST_FLOAT) &&
         ($d.theInfo.the_Type == Type.FLOAT)) {
         double val1 =  $theInfo.theVar.fValue;
         long ans1 = Double.doubleToLongBits(val1);
         TextCode.add("\t\%t" + varCount + " = frem float 0x" +Long.toHexString(ans1) + ", \%t" + $d.theInfo.theVar.varIndex);

         $theInfo.the_Type = Type.FLOAT;
         $theInfo.theVar.varIndex = varCount;
         varCount ++;
      }
      else if (($a.theInfo.the_Type != $d.theInfo.the_Type) &&  $a.theInfo.the_Type!= Type.ERR3 && $d.theInfo.the_Type!= Type.ERR3 &&  $a.theInfo.the_Type!= Type.ERR2 && $d.theInfo.the_Type!= Type.ERR2) {
			  System.out.println("Error: " + 
				                 $a.start.getLine() +
						         ": Type mismatch for the arithmetic operator in an expression.");
		      $a.theInfo.the_Type = Type.ERR2;
	  }
    }
	)*
	;

signExpr
returns [Info theInfo]
@init {$theInfo = new Info();}
   : a=primaryExpr { $theInfo=$a.theInfo; } 
   | '-' b=primaryExpr
   { 
      $theInfo=$b.theInfo;
      if ($theInfo.the_Type == Type.INT || $theInfo.the_Type == Type.CONST_INT) 
         $theInfo.theVar.iValue *= -1;
      else if ($theInfo.the_Type == Type.FLOAT || $theInfo.the_Type == Type.CONST_FLOAT)
         $theInfo.theVar.fValue *= -1;
   }
	;
		  
primaryExpr
returns [Info theInfo]
@init {$theInfo = new Info();}
   : Integer_constant 
   {
      $theInfo.the_Type = Type.CONST_INT;
      $theInfo.theVar.iValue = Integer.parseInt($Integer_constant.text);
   }
   | Floating_point_constant 
   {
      $theInfo.the_Type = Type.CONST_FLOAT;
      $theInfo.theVar.fValue = Float.parseFloat($Floating_point_constant.text);
   }
   | x = Identifier 
   {
      
      if (TRACEON) System.out.println("$theInfo.the_Type: " + $theInfo.the_Type); 
      if (symtab.containsKey($Identifier.text)) {
	        Type the_type = symtab.get($Identifier.text).the_Type;
            $theInfo.the_Type = the_type;
             int vIndex = symtab.get($Identifier.text).theVar.varIndex;
            switch (the_type) {
            case INT: 
                TextCode.add("\t\%t" + varCount + " = load i32, i32* \%t" + vIndex + ", align 4");
                $theInfo.theVar.varIndex = varCount;
                varCount ++;
                break;
            case FLOAT:
                TextCode.add("\t\%t" + varCount + " = load float, float* \%t" + vIndex + ", align 4");
                $theInfo.theVar.varIndex = varCount;
                varCount ++;
                break;
            case CHAR:
                TextCode.add("\t\%t" + varCount + " = load i8, i8* \%t" + vIndex + ", align 4");
                $theInfo.theVar.varIndex = varCount;
                varCount ++;
                break;
            }
	   } 
      else {
            System.out.println("Error: " + $Identifier.getLine() +  ": Undefined identifier : " + $Identifier.text);
	         $theInfo.the_Type = Type.ERR3;
		    
	   }
     
   }
   | '&' Identifier  {
      
      if (TRACEON) System.out.println("$theInfo.the_Type: " + $theInfo.the_Type); 
      if (symtab.containsKey($Identifier.text)) {
	        Type the_type = symtab.get($Identifier.text).the_Type;
            $theInfo.the_Type = the_type;
             int vIndex = symtab.get($Identifier.text).theVar.varIndex;
            switch (the_type) {
            case INT: 
                TextCode.add("\t\%t" + varCount + " = load i32, i32* \%t" + vIndex + ", align 4");
                $theInfo.theVar.varIndex = varCount;
                varCount ++;
                break;
            case FLOAT:
                TextCode.add("\t\%t" + varCount + " = load float, float* \%t" + vIndex + ", align 4");
                $theInfo.theVar.varIndex = varCount;
                varCount ++;
                break;
            case CHAR:
                TextCode.add("\t\%t" + varCount + " = load i8, i8* \%t" + vIndex + ", align 4");
                $theInfo.theVar.varIndex = varCount;
                varCount ++;
                break;
            }
	   } 
       else {
          
            System.out.println("Error: " + $Identifier.getLine() +  ": Undefined identifier : " + $Identifier.text);
	        $theInfo.the_Type = Type.ERR3;
		    
	   }
   }
   | '(' arith_expression ')'{$theInfo = $arith_expression.theInfo;}
   ;

		   
/* description of the tokens */

FLOAT: 'float';
INT: 'int';
CHAR: 'char';

MAIN: 'main';
VOID: 'void';
IF: 'if';
ELSE: 'else';
FOR: 'for';



Identifier
	:	LETTER (LETTER|'0'..'9')*
	;
	
fragment
LETTER
	:	'$'
	|	'A'..'Z'
	|	'a'..'z'
	|	'_'
	;

Integer_constant: ('0' | '1'..'9' '0'..'9'*);

Floating_point_constant
   : ('0'..'9')+ '.' ('0'..'9')*
	;

STRING_LITERAL
	:  '"' ( EscapeSequence | ~('\\'|'"') )* '"'
	;

fragment
EscapeSequence
	: '\\' ('b'|'t'|'n'|'f'|'r'|'\"'|'\''|'\\')
	;

WS: (' ' | '\t' | '\r' | '\n') {$channel=HIDDEN;}
	;

/* Comments */
COMMENT1
   : '//' (.)* '\n' {$channel=HIDDEN;} {skip();}
   ;

COMMENT2
   : '/*' (options{greedy=false;}: .)* '*/' {$channel=HIDDEN;} {skip();}
   ;
