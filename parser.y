%{
	#include <stdio.h>
    #include <string.h>
    #include <stdlib.h>
    #include <stdarg.h>

	extern int yylineno;

	typedef struct symbol {
        char* name;
        int decLine;
        int lastLine;
        int scope;
    } symbol;

    static symbol symbolTable[500];

    static int symbolCount = -1;

    static int searchSymbol(char* name) {
        int i = 0;
        for (i = 0; i < symbolCount; i++) {
            if((strcmp(symbolTable[i].name, name)==0))
			{
				return i;
			}
        }
        return -1;
    }

    static void modifySymbol(int symbolId, int lineNo) {
		symbolTable[symbolId].lastLine = lineNo;
	}

    static void insertSymbol(char* name, int lineNo, int scope) {
        symbolCount++;

        symbolTable[symbolCount].name = (char*)malloc(30 * sizeof(char));
        strcpy(symbolTable[symbolCount].name, name);

        symbolTable[symbolCount].decLine = lineNo;
        symbolTable[symbolCount].lastLine = lineNo;
        symbolTable[symbolCount].scope = scope;
    }

    static void printSTable() {
        printf("\n\nSl No.\tSymbol\t\tDeclaration Line\tLast Used Line\t\tScope\n\n");
        printf("==============================================================================\n\n");
		int i = 0;
		for(i = 0; i <= symbolCount; i++)
		{
			printf("%d\t%s\t\t%d\t\t\t%d\t\t\t%d\n", i+1, symbolTable[i].name, symbolTable[i].decLine, symbolTable[i].lastLine, symbolTable[i].scope);
		}
        printf("\n\n");
    }
%}

%union { 
	char* text;
	char* num;
	char* str;
}

%token NOCHANGE NEWLINE DEDENT INDENT IMPORT WHILE IF ELIF ELSE IN PASS BREAK RETURN COLON GT LT GE LE EE NE TRUE FALSE OP CP OB CB NUMBER ID STRING ENDFILE

%right EQL                                          
%left PL MN
%left ML DV
%left NOT
%left AND
%left OR

%nonassoc IF
%nonassoc ELIF
%nonassoc ELSE

%%

startparse: start ENDFILE;
start: NEWLINE start | statements NEWLINE start | statements NEWLINE ;

constant: NUMBER | STRING ;
term: ID | constant ;
expressions: arith_expr | bool_expr;
arith_expr: term | arith_expr PL arith_expr
			| arith_expr MN arith_expr
			| arith_expr ML arith_expr
			| arith_expr DV arith_expr ;
relational_op: GT | LT | GE | LE;
bool_expr: TRUE | FALSE | OP bool_expr CP | arith_expr relational_op arith_expr
		  | bool_expr AND bool_expr
		  | bool_expr OR bool_expr
		  | NOT bool_expr
		  | expressions EE expressions | expressions NE expressions;

import_stmt: IMPORT ID;
pass_stmt: PASS;
break_stmt: BREAK;
assign_stmt: ID EQL expressions;

if_stmt: IF bool_expr COLON start_suite |
         IF bool_expr COLON start_suite elif_stmts ;
elif_stmts: ELIF bool_expr COLON start_suite elif_stmts | else_stmt ;
else_stmt: ELSE COLON start_suite;

while_stmt: WHILE bool_expr COLON start_suite;

basic_stmt: import_stmt | pass_stmt | break_stmt | assign_stmt | expressions;
cmpd_stmt: if_stmt | while_stmt;
statements: basic_stmt | cmpd_stmt;

start_suite: basic_stmt | NEWLINE INDENT statements suite;
suite: NEWLINE NOCHANGE statements suite | NEWLINE end_suite;
end_suite: DEDENT statements | ;

%%

void yyerror(const char* text) {
	printf("Syntax Error at Line %d\n", yylineno);
}

int main() {
	yyparse();
}