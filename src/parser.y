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

    typedef struct ASTNode
    {
        int nodeNo;
        char *nodeType;
        int noOperands;
        struct ASTNode* left;
        struct ASTNode* middle;
        struct ASTNode* right;
        
        symbol *id; 
    }node;

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

    node* createOp(char* operation,int noOperands,node* left,node* middle,node* right)
    {

        node* newNode = (node*)calloc(1,sizeof(node));

        newNode->left = left;
        newNode->middle = middle;
        newNode->right = right;
        newNode->noOperands = noOperands;

        newNode->nodeType = (char*)malloc( sizeof(char) * ( strlen(operation) + 1 ) );
        strcpy(newNode->nodeType,operation);

        return newNode;
    }

    void displayAST(node* root)
    {
        if(root->noOperands == 3)
        {
            printf(" ( ");
            printf(" %s ",root->nodeType);
            displayAST(root->left);
            displayAST(root->middle);
            displayAST(root->right);
            printf(" ) ");
        }
        else if(root->noOperands == 2)
        {
            printf(" ( ");
            printf(" %s ",root->nodeType);
            displayAST(root->left);
            displayAST(root->middle);
            printf(" ) ");
        }
        else if(root->noOperands == 1)
        {
            printf(" ( ");
            printf(" %s ",root->nodeType);
            displayAST(root->left);
            printf(" ) ");
        }
        else if(root->noOperands == 0)
        {
            printf(" ( ");
            printf(" %s ",root->nodeType);
            printf(" ) ");
        }
    }

%}

%union { 
	char* text;
	char* num;
	char* str;
    int depth;
    struct ASTNode* NODE;
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

%type <NODE> startparse start constant term expressions
%type <NODE> arith_expr bool_expr bool_term bool_factor import_stmt
%type <NODE> pass_stmt break_stmt assign_stmt if_stmt elif_stmts
%type <NODE> else_stmt while_stmt args call_params func_def func_call 
%type <NODE> basic_stmt cmpd_stmt statements start_suite suite end_suite

%%

startparse: {init();} start  ENDFILE   {
                                printf("\nValid Python Syntax\n"); 
                                printSTable();
                                displayAST($2);
                                exit(0);
                            } ;
start: NEWLINE start {$$=$2;} 
    | statements NEWLINE start {$$ = createOp("NewLine", 2, $1, $3,NULL); };
    | statements NEWLINE {$$=$1;};

constant: NUMBER {$$ = createOp($<text>1,0,NULL,NULL,NULL); } 
        | STRING {$$ = createOp($<text>1,0,NULL,NULL,NULL); };
term: ID {$$ = createOp($<text>1,0,NULL,NULL,NULL); }
    | constant {$$ = $1;} ;
expressions: arith_expr {$$=$1;}| bool_expr {$$=$1;};
arith_expr: term {$$=$1;} 
            | arith_expr PL arith_expr {$$ = createOp("+", 2, $1, $3,NULL);}
			| arith_expr MN arith_expr {$$ = createOp("-", 2, $1, $3,NULL);}
			| arith_expr ML arith_expr {$$ = createOp("*", 2, $1, $3,NULL);}
			| arith_expr DV arith_expr {$$ = createOp("/", 2, $1, $3,NULL);}
            | MN arith_expr {$$ = createOp("-", 1, $2,NULL,NULL);}
            | OP arith_expr CP {$$ = $2;};
bool_term: TRUE {$$ = createOp("True",0,NULL,NULL,NULL); }
          | FALSE {$$ = createOp("False",0,NULL,NULL,NULL); }
          | arith_expr EE arith_expr {$$ = createOp("==", 2, $1, $3,NULL);}
          | bool_factor {$$ = $1;};
bool_factor: NOT bool_factor {$$ = createOp("!", 1, $2,NULL,NULL);}
          | OP bool_expr CP {$$ = $2;};  
bool_expr: arith_expr GT arith_expr {$$ = createOp(">", 2, $1, $3,NULL);}
          | arith_expr LT arith_expr {$$ = createOp("<", 2, $1, $3,NULL);}
          | arith_expr GE arith_expr {$$ = createOp(">=", 2, $1, $3,NULL);}
          | arith_expr LE arith_expr {$$ = createOp("<=", 2, $1, $3,NULL);}
		  | bool_term AND bool_term {$$ = createOp("AND", 2, $1, $3,NULL);}
		  | bool_term OR bool_term {$$ = createOp("or", 2, $1, $3,NULL);}
		  | bool_term {$$=$1;};

import_stmt: IMPORT ID { $$ = createOp("import", 1, createOp("PackageName", $<text>2, NULL,NULL,NULL),NULL,NULL );};
pass_stmt: PASS {$$ = createOp("pass", 0,NULL,NULL,NULL);};
break_stmt: BREAK {$$ = createOp("break", 0,NULL,NULL,NULL);};
assign_stmt: ID EQL expressions {
                                    insertSymbol("Identifier", $<text>1, yylineno, currentScope);
                                    $$ = createOp("=", 2, createOp($<text>1, 0,NULL,NULL,NULL), $3,NULL);
                                }
            | ID EQL func_call  {
                                    insertSymbol("Identifier", $<text>1, yylineno, currentScope);
                                    $$ = createOp("=", 2, createOp($<text>1, 0,NULL,NULL,NULL), $3,NULL);
                                }; 

if_stmt: IF bool_expr COLON start_suite %prec LOWER_THAN_EL {$$ = createOp("If", 2, $2, $4,NULL);}
       | IF bool_expr COLON start_suite elif_stmts {$$ = createOp("If", 3, $2, $4, $5);};
elif_stmts: ELIF bool_expr COLON start_suite elif_stmts {$$= createOp("Elif", 3, $2, $4, $5);}
          | else_stmt {$$= $1;};
else_stmt: ELSE COLON start_suite {$$ = createOp("Else", 1, $3,NULL,NULL);};

while_stmt: WHILE bool_expr COLON start_suite {$$ = createOp("While", 2, $2, $4,NULL);};

args_list: COMMA ID args_list | ;
args: ID args_list {$$ = createOp("TO DO", 0,NULL,NULL,NULL);} 
    | {$$ = createOp("Void", 0,NULL,NULL,NULL);};
call_list: COMMA term call_list | ;
call_params: term call_list {$$ = createOp("TO DO", 0,NULL,NULL,NULL);};

func_def: DEF ID OP args CP COLON {
                                    insertSymbol("Function", $<text>2, yylineno, currentScope);
                                    currentScope = $<text>2;
                                  } 
          start_suite {
                        strcpy(currentScope, "Global");
                        $$ = createOp("Func_Name", 3, createOp($<text>2,0,NULL,NULL,NULL), $4, $8);  
                      };
func_call: ID OP call_params CP {
                                    insertSymbol("Function", $<text>2, yylineno, currentScope);
                                    $$ = createOp("Func_Call", 2, createOp($<text>1,0,NULL,NULL,NULL), $3,NULL);
                                } ;

basic_stmt: import_stmt {$$=$1;}
            | pass_stmt {$$=$1;}
            | break_stmt {$$=$1;}
            | assign_stmt {$$=$1;}
            | expressions {$$=$1;};
cmpd_stmt: if_stmt {$$ = $1;}
        | while_stmt {$$ = $1;};

statements: basic_stmt {$$ = $1;}
        | cmpd_stmt {$$ = $1;}
        | func_def {$$ = $1;}
        | func_call {$$ = $1;};

start_suite: basic_stmt {$$ = $1;} 
            | NEWLINE INDENT statements suite {$$ = createOp("BeginBlock", 2, $3, $4,NULL);};

suite: NEWLINE NOCHANGE statements suite {$$ = createOp("Next", 2, $3, $4,NULL);}
        | NEWLINE end_suite {$$ = $2;};

end_suite: DEDENT {$$ = createOp("EndBlock", 0, NULL,NULL,NULL);}
           | DEDENT statements {$$ = createOp("EndBlock", 1, $2,NULL,NULL);}
           | {$$ = createOp("EndBlock", 0, NULL,NULL,NULL); resetDepth();};

%%

void yyerror(const char* text) {
	printf("Syntax Error at Line %d\n", yylineno);
}

int main() {
	yyparse();
}