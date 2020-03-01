%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
            
        
%}

%token NEWLINE INDENT DEDENT IMPORT  WHILE IF ELIF ELSE IN  OR AND NOT PASS BREAK  RETURN COLON GT LT GE
    LE EE NE TRUE FALSE PL MN ML DV OP CP OB CB  EQL NUMBER ID STRING  NOCHANGE
%left AND OR IN NOT 
%left GE LE NE EE GT LT 
%left PL MN
%left ML DV 

%%

constant : NUMBER {insertRecord("Constant", $<text>1, @1.first_line, currentScope); $$ = createID_Const("Constant", $<text>1, currentScope);}
          | STRING {insertRecord("Constant", $<text>1, @1.first_line, currentScope); $$ = createID_Const("Constant", $<text>1, currentScope);};

term : ID {modifyRecordID("Identifier", $<text>1, @1.first_line, currentScope); $$ = createID_Const("Identifier", $<text>1, currentScope);} 
     | constant {$$ = $1;} 


basic_stmt: pass_stmt {$$=$1;}
           | break_stmt {$$=$1;}
           | import_stmt {$$=$1;}
           | assign_stmt {$$=$1;}
           | arith_exp {$$=$1;}
           | bool_exp {$$=$1;}
           | return_stmt {$$=$1;};

arith_exp: term {$$=$1;}
          | arith_exp  PL  arith_exp {$$ = createOp("+", 2, $1, $3);}
          | arith_exp  MN  arith_exp {$$ = createOp("-", 2, $1, $3);}
          | arith_exp  ML  arith_exp {$$ = createOp("*", 2, $1, $3);}
          | arith_exp  DV  arith_exp {$$ = createOp("/", 2, $1, $3);}
          | MN arith_exp {$$ = createOp("-", 1, $2);}
          | OP arith_exp CP {$$ = $2;};
 
bool_exp: bool_term OR bool_term {$$ = createOp("or", 2, $1, $3);}
         | arith_exp LT arith_exp {$$ = createOp("<", 2, $1, $3);}
         | bool_term AND bool_term {$$ = createOp("and", 2, $1, $3);}
         | arith_exp GT arith_exp {$$ = createOp(">", 2, $1, $3);}
         | arith_exp LE arith_exp {$$ = createOp("<=", 2, $1, $3);}
         | arith_exp GE arith_exp {$$ = createOp(">=", 2, $1, $3);}
         | arith_exp IN ID {checkList($<text>3, @3.first_line, currentScope); $$ = createOp("in", 2, $1, createID_Const("Constant", $<text>3, currentScope));}
         | bool_term {$$=$1;}; 

bool_term: bool_factor {$$ = $1;}
          | arith_exp EE arith_exp {$$ = createOp("==", 2, $1, $3);}
          |  arith_exp NE arith_exp {$$ = createOp("!=", 2, $1, $3);}
          | TRUE {insertRecord("Constant", "True", @1.first_line, currentScope); $$ = createID_Const("Constant", "True", currentScope);}
          | FALSE {insertRecord("Constant", "False", @1.first_line, currentScope); $$ = createID_Const("Constant", "False", currentScope);}; 
          
bool_factor: NOT bool_factor {$$ = createOp("!", 1, $2);}
            | OP bool_exp CP {$$ = $2;}; 

import_stmt: IMPORT ID {insertRecord("PackageName", $<text>2, @2.first_line, currentScope); $$ = createOp("import", 1, createID_Const("PackageName", $<text>2, currentScope));};
pass_stmt: PASS {$$ = createOp("pass", 0);};
break_stmt: BREAK {$$ = createOp("break", 0);};
return_stmt: RETURN {$$ = createOp("return", 0);};;

assign_stmt: ID EQL arith_exp {insertRecord("Identifier", $<text>1, @1.first_line, currentScope); $$ = createOp("=", 2, createID_Const("Identifier", $<text>1, currentScope), $3);}  
            | ID EQL bool_exp {insertRecord("Identifier", $<text>1, @1.first_line, currentScope);$$ = createOp("=", 2, createID_Const("Identifier", $<text>1, currentScope), $3);}   
            | ID EQL OB CB {insertRecord("ListTypeID", $<text>1, @1.first_line, currentScope); $$ = createID_Const("ListTypeID", $<text>1, currentScope);} ;

finalStatements: basic_stmt {$$ = $1;}
                | cmpd_stmt {$$ = $1;}
                | error NEWLINE {yyerrok; yyclearin; $$=createOp("SyntaxError", 0);};

cmpd_stmt: if_stmt {$$ = $1;} | while_stmt {$$ = $1;};


if_stmt: IF bool_exp COLON start_suite {$$ = createOp("If", 2, $2, $4);}
        | IF bool_exp COLON start_suite elif_stmts {$$ = createOp("If", 3, $2, $4, $5);};

elif_stmts : else_stmt {$$= $1;}
           | ELIF bool_exp COLON start_suite elif_stmts {$$= createOp("Elif", 3, $2, $4, $5);};

else_stmt : ELSE COLON start_suite {$$ = createOp("Else", 1, $3);};

while_stmt : WHILE bool_exp COLON start_suite {$$ = createOp("While", 2, $2, $4);}; 

start_suite : basic_stmt {$$ = $1;}
            | NEWLINE INDENT {initNewTable($<depth>2); updateCScope($<depth>2);} finalStatements suite {$$ = createOp("BeginBlock", 2, $4, $5);};

suite : NEWLINE NOCHANGE finalStatements suite {$$ = createOp("Next", 2, $3, $4);}
      | NEWLINE end_suite {$$ = $2;};

end_suite : DEDENT {updateCScope($<depth>1);} finalStatements {$$ = createOp("EndBlock", 1, $3);} 
          | DEDENT {updateCScope($<depth>1);} {$$ = createOp("EndBlock", 0);}
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






