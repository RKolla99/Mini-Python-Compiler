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
simple_stmt: small_stmt NEWLINE ;
small_stmt: pass_stmt | flow_stmt ;
stmt: small_stmt | compound_stmt;
pass_stmt: PASS ;
flow_stmt: break_stmt | continue_stmt ;
break_stmt: BREAK ;
continue_stmt: CONTINUE ;
compound_stmt: if_stmt | while_stmt | for_stmt;
if_stmt: IF test COLON suite 
		| IF test COLON suite if_follow ELSE COLON suite 
		| IF test COLON suite ELSE COLON suite ;
if_follow: ELIF test COLON suite if_follow
            | ;
while_stmt: WHILE test COLON suite 
		| WHILE test COLON suite ELSE COLON suite;
for_stmt: FOR ID IN testlist COLON suite
		| FOR ID IN testlist COLON suite ELSE COLON suite;
testlist: test_nocond repeat_test optional_comma ;
repeat_test: COMMA test_nocond repeat_test
	| ;
optional_comma: COMMA
	| ;
suite: simple_stmt | INDENT stmt suite1 DEDENT | NEWLINE;
suite1: INDENT stmt suite1;
test: or_test IF or_test ELSE test;
test_nocond: or_test;
or_test: and_test or1_test;
or1_test: OR and_test 
            | ;
and_test: not_test and1_test ;
and1_test: AND not_test and1_test 
            | ;
not_test: NOT not_test | comparison;
comparison: expr comparison1;
comparison1: comp_op expr comparison1 
            | ;
comp_op: LT | GT | EE | GE | LE | NE | IN | NOT IN | IS | IS NOT  ;
star_expr: ML expr;
expr: xor_expr expr1;
expr1: BOR xor_expr expr1 
        | ;
xor_expr: and_expr  xor1_expr ;
xor1_expr: XOR and_expr xor1_expr 
        | ;
and_expr: and1_expr;
and1_expr: BAND and1_expr 
        | ;
arith_expr: term arith1_expr;
arith1_expr: PL term arith1_expr  
        | MN term arith1_expr 
        | ;
term: factor term1 ;
term1: ML factor 
        | DV factor
        | MOD factor 
        | ;
factor: PL factor 
        | MN factor 
        | atom;
atom:  ID | NUMBER | STRING atom1 | NONE | TRUE | FALSE ;
atom1: STRING atom1;

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
