%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
            
        
%}

%token NEWLINE INDENT DEDENT IMPORT DEF FOR WHILE IF ELIF ELSE IN IS OR AND NOT PASS BREAK CONTINUE RETURN COLON GT LT GE
    LE EE NE TRUE FALSE PL MN ML DV OP CP OB CB COMMA EQL NUMBER ID STRING XOR BAND BOR NONE
%left AND OR IN NOT XOR 
%left GE LE NE EE GT LT 
%left PL MN
%left ML DV MOD

%%


single_input: NEWLINE | simple_stmt | compound_stmt NEWLINE ;

basic_stmt: pass_stmt {$$=$1;}
           | break_stmt {$$=$1;}
           | import_stmt {$$=$1;}
           | assign_stmt {$$=$1;}
           | arith_exp {$$=$1;}
           | bool_exp {$$=$1;}
           | print_stmt {$$=$1;}
           | return_stmt {$$=$1;};

arith_exp: term {$$=$1;}
          | arith_exp  T_PL  arith_exp {$$ = createOp("+", 2, $1, $3);}
          | arith_exp  T_MN  arith_exp {$$ = createOp("-", 2, $1, $3);}
          | arith_exp  T_ML  arith_exp {$$ = createOp("*", 2, $1, $3);}
          | arith_exp  T_DV  arith_exp {$$ = createOp("/", 2, $1, $3);}
          | T_MN arith_exp {$$ = createOp("-", 1, $2);}
          | T_OP arith_exp T_CP {$$ = $2;} ;
		    

bool_exp: bool_term T_Or bool_term {$$ = createOp("or", 2, $1, $3);}
         | arith_exp T_LT arith_exp {$$ = createOp("<", 2, $1, $3);}
         | bool_term T_And bool_term {$$ = createOp("and", 2, $1, $3);}
         | arith_exp T_GT arith_exp {$$ = createOp(">", 2, $1, $3);}
         | arith_exp T_ELT arith_exp {$$ = createOp("<=", 2, $1, $3);}
         | arith_exp T_EGT arith_exp {$$ = createOp(">=", 2, $1, $3);}
         | arith_exp T_In T_ID {checkList($<text>3, @3.first_line, currentScope); $$ = createOp("in", 2, $1, createID_Const("Constant", $<text>3, currentScope));}
         | bool_term {$$=$1;}; 

bool_term: bool_factor {$$ = $1;}
          | arith_exp T_EQ arith_exp {$$ = createOp("==", 2, $1, $3);}
          | T_True {insertRecord("Constant", "True", @1.first_line, currentScope); $$ = createID_Const("Constant", "True", currentScope);}
          | T_False {insertRecord("Constant", "False", @1.first_line, currentScope); $$ = createID_Const("Constant", "False", currentScope);}; 
          
bool_factor: T_Not bool_factor {$$ = createOp("!", 1, $2);}
            | T_OP bool_exp T_CP {$$ = $2;}; 

import_stmt: T_Import T_ID {insertRecord("PackageName", $<text>2, @2.first_line, currentScope); $$ = createOp("import", 1, createID_Const("PackageName", $<text>2, currentScope));};
pass_stmt: T_Pass {$$ = createOp("pass", 0);};
break_stmt: T_Break {$$ = createOp("break", 0);};
return_stmt: T_Return {$$ = createOp("return", 0);};;

assign_stmt: T_ID T_EQL arith_exp {insertRecord("Identifier", $<text>1, @1.first_line, currentScope); $$ = createOp("=", 2, createID_Const("Identifier", $<text>1, currentScope), $3);}  
            | T_ID T_EQL bool_exp {insertRecord("Identifier", $<text>1, @1.first_line, currentScope);$$ = createOp("=", 2, createID_Const("Identifier", $<text>1, currentScope), $3);}   
            | T_ID T_EQL T_OB T_CB {insertRecord("ListTypeID", $<text>1, @1.first_line, currentScope); $$ = createID_Const("ListTypeID", $<text>1, currentScope);} ;
	      
print_stmt: T_Print T_OP term T_CP {$$ = createOp("Print", 1, $3);};

finalStatements: basic_stmt {$$ = $1;}
                | cmpd_stmt {$$ = $1;}
                | error T_NL {yyerrok; yyclearin; $$=createOp("SyntaxError", 0);};

cmpd_stmt: if_stmt {$$ = $1;} | while_stmt {$$ = $1;};


if_stmt: T_If bool_exp T_Cln start_suite {$$ = createOp("If", 2, $2, $4);}
        | T_If bool_exp T_Cln start_suite elif_stmts {$$ = createOp("If", 3, $2, $4, $5);};

elif_stmts : else_stmt {$$= $1;}
           | T_Elif bool_exp T_Cln start_suite elif_stmts {$$= createOp("Elif", 3, $2, $4, $5);};

else_stmt : T_Else T_Cln start_suite {$$ = createOp("Else", 1, $3);};

while_stmt : T_While bool_exp T_Cln start_suite {$$ = createOp("While", 2, $2, $4);}; 

start_suite : basic_stmt {$$ = $1;}
            | T_NL ID {initNewTable($<depth>2); updateCScope($<depth>2);} finalStatements suite {$$ = createOp("BeginBlock", 2, $4, $5);};

suite : T_NL ND finalStatements suite {$$ = createOp("Next", 2, $3, $4);}
      | T_NL end_suite {$$ = $2;};

end_suite : DD {updateCScope($<depth>1);} finalStatements {$$ = createOp("EndBlock", 1, $3);} 
          | DD {updateCScope($<depth>1);} {$$ = createOp("EndBlock", 0);}
          | {$$ = createOp("EndBlock", 0); resetDepth();};


%%


void yyerror()
{
    printf("Syntax error in line %d", yylineno);
    exit(0);
}

int main() {
    yyparse();
    printf("Valid input");
}







// Current grammar



constant : T_Number {insertRecord("Constant", $<text>1, @1.first_line, currentScope); $$ = createID_Const("Constant", $<text>1, currentScope);}
          | T_String {insertRecord("Constant", $<text>1, @1.first_line, currentScope); $$ = createID_Const("Constant", $<text>1, currentScope);};
term : T_ID {modifyRecordID("Identifier", $<text>1, @1.first_line, currentScope); $$ = createID_Const("Identifier", $<text>1, currentScope);} 
     | constant {$$ = $1;} 

basic_stmt : pass_stmt {$$=$1;}
           | break_stmt {$$=$1;}
           | import_stmt {$$=$1;}
           | assign_stmt {$$=$1;}
           | arith_exp {$$=$1;}
           | bool_exp {$$=$1;}
           | print_stmt {$$=$1;}
           | return_stmt {$$=$1;};

arith_exp : term {$$=$1;}
          | arith_exp  T_PL  arith_exp {$$ = createOp("+", 2, $1, $3);}
          | arith_exp  T_MN  arith_exp {$$ = createOp("-", 2, $1, $3);}
          | arith_exp  T_ML  arith_exp {$$ = createOp("*", 2, $1, $3);}
          | arith_exp  T_DV  arith_exp {$$ = createOp("/", 2, $1, $3);}
          | T_MN arith_exp {$$ = createOp("-", 1, $2);}
          | T_OP arith_exp T_CP {$$ = $2;} ;
		    

bool_exp : bool_term T_Or bool_term {$$ = createOp("or", 2, $1, $3);}
         | arith_exp T_LT arith_exp {$$ = createOp("<", 2, $1, $3);}
         | bool_term T_And bool_term {$$ = createOp("and", 2, $1, $3);}
         | arith_exp T_GT arith_exp {$$ = createOp(">", 2, $1, $3);}
         | arith_exp T_ELT arith_exp {$$ = createOp("<=", 2, $1, $3);}
         | arith_exp T_EGT arith_exp {$$ = createOp(">=", 2, $1, $3);}
         | arith_exp T_In T_ID {checkList($<text>3, @3.first_line, currentScope); $$ = createOp("in", 2, $1, createID_Const("Constant", $<text>3, currentScope));}
         | bool_term {$$=$1;}; 

bool_term : bool_factor {$$ = $1;}
          | arith_exp T_EQ arith_exp {$$ = createOp("==", 2, $1, $3);}
          | T_True {insertRecord("Constant", "True", @1.first_line, currentScope); $$ = createID_Const("Constant", "True", currentScope);}
          | T_False {insertRecord("Constant", "False", @1.first_line, currentScope); $$ = createID_Const("Constant", "False", currentScope);}; 
          
bool_factor : T_Not bool_factor {$$ = createOp("!", 1, $2);}
            | T_OP bool_exp T_CP {$$ = $2;}; 

import_stmt : T_Import T_ID {insertRecord("PackageName", $<text>2, @2.first_line, currentScope); $$ = createOp("import", 1, createID_Const("PackageName", $<text>2, currentScope));};
pass_stmt : T_Pass {$$ = createOp("pass", 0);};
break_stmt : T_Break {$$ = createOp("break", 0);};
return_stmt : T_Return {$$ = createOp("return", 0);};;

assign_stmt : T_ID T_EQL arith_exp {insertRecord("Identifier", $<text>1, @1.first_line, currentScope); $$ = createOp("=", 2, createID_Const("Identifier", $<text>1, currentScope), $3);}  
            | T_ID T_EQL bool_exp {insertRecord("Identifier", $<text>1, @1.first_line, currentScope);$$ = createOp("=", 2, createID_Const("Identifier", $<text>1, currentScope), $3);}   
            | T_ID T_EQL T_OB T_CB {insertRecord("ListTypeID", $<text>1, @1.first_line, currentScope); $$ = createID_Const("ListTypeID", $<text>1, currentScope);} ;
	      
print_stmt : T_Print T_OP term T_CP {$$ = createOp("Print", 1, $3);};

finalStatements : basic_stmt {$$ = $1;}
                | cmpd_stmt {$$ = $1;}
                | error T_NL {yyerrok; yyclearin; $$=createOp("SyntaxError", 0);};

cmpd_stmt : if_stmt {$$ = $1;}
          | while_stmt {$$ = $1;};


if_stmt : T_If bool_exp T_Cln start_suite {$$ = createOp("If", 2, $2, $4);}
        | T_If bool_exp T_Cln start_suite elif_stmts {$$ = createOp("If", 3, $2, $4, $5);};

elif_stmts : else_stmt {$$= $1;}
           | T_Elif bool_exp T_Cln start_suite elif_stmts {$$= createOp("Elif", 3, $2, $4, $5);};

else_stmt : T_Else T_Cln start_suite {$$ = createOp("Else", 1, $3);};

while_stmt : T_While bool_exp T_Cln start_suite {$$ = createOp("While", 2, $2, $4);}; 

start_suite : basic_stmt {$$ = $1;}
            | T_NL ID {initNewTable($<depth>2); updateCScope($<depth>2);} finalStatements suite {$$ = createOp("BeginBlock", 2, $4, $5);};

suite : T_NL ND finalStatements suite {$$ = createOp("Next", 2, $3, $4);}
      | T_NL end_suite {$$ = $2;};

end_suite : DD {updateCScope($<depth>1);} finalStatements {$$ = createOp("EndBlock", 1, $3);} 
          | DD {updateCScope($<depth>1);} {$$ = createOp("EndBlock", 0);}
          | {$$ = createOp("EndBlock", 0); resetDepth();};



