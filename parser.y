%{
	#include <stdio.h>
    #include <string.h>
    #include <stdlib.h>
    #include <stdarg.h>

	extern int yylineno;
    extern int depth;
    extern int top();
    extern int pop();

	typedef struct symbol {
        char* type;
        char* name;
        int decLine;
        int lastLine;
        char* scope;
    } symbol;

    static symbol symbolTable[500];

    static int symbolCount = -1;

    char* currentScope;

    static void init() {
        currentScope = (char*)malloc(30 * sizeof(char));
        strcpy(currentScope, "Global");
    }

    static int searchSymbol(char* name) {
        int i = 0;
        for (i = 0; i < symbolCount + 1; i++) {
            if((strcmp(symbolTable[i].name, name) == 0))
			{
				return i;
			}
        }
        return -1;
    }

    static void modifySymbol(int symbolId, int lineNo) {
		symbolTable[symbolId].lastLine = lineNo;
	}

    static void insertSymbol(char* type, char* name, int lineNo, char* scope) {
        int find = searchSymbol(name);
        --lineNo;

        if (find > -1) {
            modifySymbol(find, lineNo);
        }

        else {

            symbolCount++;

            symbolTable[symbolCount].type = (char*)malloc(30 * sizeof(char));
            symbolTable[symbolCount].name = (char*)malloc(30 * sizeof(char));
            symbolTable[symbolCount].scope = (char*)malloc(30 * sizeof(char));

            
            strcpy(symbolTable[symbolCount].type, type);
            strcpy(symbolTable[symbolCount].name, name);

            symbolTable[symbolCount].decLine = lineNo;
            symbolTable[symbolCount].lastLine = lineNo;

            strcpy(symbolTable[symbolCount].scope, scope);

        }
    }

    static void printSTable() {
        printf("\n\nSl No.\tType\t\t\tSymbol\t\tDeclaration Line\tLast Used Line\t\tScope\n\n");
        printf("========================================================================================================\n\n");
		int i = 0;
		for(i = 0; i <= symbolCount; i++)
		{
			printf("%d\t%s\t\t%s\t\t%d\t\t\t%d\t\t\t%s\n", i+1, symbolTable[i].type, symbolTable[i].name, symbolTable[i].decLine, symbolTable[i].lastLine, symbolTable[i].scope);
		}
        printf("\n\n");
    }

    static void createNestedScope(char* function) {
        char* temp = (char*)malloc(30 * sizeof(char));
        strcpy(temp, strcat(" > ", function));
        strcpy(currentScope, strcat(currentScope, temp));
    }

    void resetDepth() {
        while(top())
            pop();

        depth = 1;
    }


%}

%union { 
	char* text;
	char* num;
	char* str;
    int depth;
}

%token NOCHANGE NEWLINE DEDENT INDENT IMPORT WHILE IF ELIF ELSE IN PASS BREAK RETURN DEF COLON GT LT GE LE EE NE TRUE FALSE OP CP OB CB NUMBER ID STRING COMMA ENDFILE

%right EQL                                          
%left PL MN
%left ML DV
%left NOT
%left AND
%left OR

%nonassoc LOWER_THAN_EL
%nonassoc ELSE
%nonassoc ELIF

%%

startparse: {init();} start  ENDFILE   {
                                printf("\nValid Python Syntax\n"); 
                                printSTable();
                                exit(0);
                            } ;
start: NEWLINE start | statements NEWLINE start | statements NEWLINE ;

constant: NUMBER | STRING ;
term: ID | constant ;
expressions: arith_expr | bool_expr;
arith_expr: term | arith_expr PL arith_expr
			| arith_expr MN arith_expr
			| arith_expr ML arith_expr
			| arith_expr DV arith_expr 
            | MN arith_expr
            | OP arith_expr CP ;
bool_term: TRUE
          | FALSE
          | arith_expr EE arith_expr
          | bool_factor ;
bool_factor: NOT bool_factor
          | OP bool_expr CP ;  
bool_expr: arith_expr GT arith_expr
          | arith_expr LT arith_expr
          | arith_expr GE arith_expr
          | arith_expr LE arith_expr  
		  | bool_term AND bool_term
		  | bool_term OR bool_term
		  | bool_term ;

import_stmt: IMPORT ID;
pass_stmt: PASS;
break_stmt: BREAK;
assign_stmt: ID EQL expressions {
                                    insertSymbol("Identifier", $<text>1, yylineno, currentScope);
                                }
            | ID EQL func_call  {
                                    insertSymbol("Identifier", $<text>1, yylineno, currentScope);
                                }; 

if_stmt: IF bool_expr COLON start_suite %prec LOWER_THAN_EL |
         IF bool_expr COLON start_suite elif_stmts ;
elif_stmts: ELIF bool_expr COLON start_suite elif_stmts | else_stmt ;
else_stmt: ELSE COLON start_suite;

while_stmt: WHILE bool_expr COLON start_suite;

args_list: COMMA ID args_list | ;
args: ID args_list | ;
call_list: COMMA term call_list | ;
call_params: term call_list ;

func_def: DEF ID OP args CP COLON {
                                    insertSymbol("Function", $<text>2, yylineno, currentScope);
                                    currentScope = $<text>2;
                                  } 
          start_suite {strcpy(currentScope, "Global");};
func_call: ID OP call_params CP {
                                    insertSymbol("Function", $<text>2, yylineno, currentScope);
                                } ;

basic_stmt: import_stmt | pass_stmt | break_stmt | assign_stmt | expressions;
cmpd_stmt: if_stmt | while_stmt;
statements: basic_stmt | cmpd_stmt | func_def | func_call ;

start_suite: basic_stmt | NEWLINE INDENT statements suite ;
suite: NEWLINE NOCHANGE statements suite | NEWLINE end_suite;
end_suite: DEDENT
           | DEDENT statements 
           | {resetDepth();};

%%

void yyerror(const char* text) {
	printf("Syntax Error at Line %d\n", yylineno);
}

int main() {
	yyparse();
}