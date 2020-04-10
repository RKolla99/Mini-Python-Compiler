%{
	#include <stdio.h>
    #include <string.h>
    #include <stdlib.h>
    #include <stdarg.h>

	#define RESET   "\033[0m"
    #define RED     "\033[31m"
    #define GREEN   "\033[32m"


	extern int yylineno;
    extern int depth;
	extern int isError;
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
    } node;
    

    typedef struct quad
    {
        char * Result;
        char * op1;
        char * op2;
        char * operator;
        int Index;

		int loopFlag;
    } Quad;

    typedef struct Error
    {
        int type;
        char* msg;
        int lineNo;
    } Error;

    static symbol symbolTable[500];

	static int startFlag = 0;
    static int symbolCount = -1;
    static int labelIndex=0;
    static int qIndex=0;
    static int oldQIndex = 0;
	static int nodeCount = 0;
    static int ErrorIndex = 0;
    static Quad* threeAddressQueue = NULL;
	static Quad* optimisedThreeAddressQueue = NULL;
    static Quad* copyFreeThreeAddressQueue = NULL;
	static Quad* tempQueue = NULL;
    static char* currentScope;
	static char* tString = NULL, *lString = NULL;
    static Error* errors = NULL;

    static void init() 
    {
		tString = (char*)calloc(10, sizeof(char));
		lString = (char*)calloc(10, sizeof(char));
		threeAddressQueue = (Quad*)calloc(1000, sizeof(Quad));
        currentScope = (char*)malloc(30 * sizeof(char));
        strcpy(currentScope, "Global");
        errors = (Error*)calloc(100, sizeof(Error));
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

    static void modifySymbol(int symbolId, int lineNo) 
    {
		symbolTable[symbolId].lastLine = lineNo;
	}

    static void insertSymbol(char* type, char* name, int lineNo, char* scope)
    {
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

    static void printSTable()
    {
        printf("\n\nSl No.\tType\t\t\tSymbol\t\tDeclaration Line\tLast Used Line\t\tScope\n\n");
        printf("========================================================================================================\n\n");
		int i = 0;
		for(i = 0; i <= symbolCount; i++)
		{
			printf("%d\t%s\t\t%s\t\t%d\t\t\t%d\t\t\t%s\n", i+1, symbolTable[i].type, symbolTable[i].name, symbolTable[i].decLine, symbolTable[i].lastLine, symbolTable[i].scope);
		}
        printf("\n\n\n\n");
    }

    void resetDepth()
    {
        while(top())
            pop();

        depth = 1;
    }

    node* createOp(char* operation, int noOperands, node* left, node* middle, node* right)
    {
        node* newNode = (node*)calloc(1, sizeof(node));

        newNode->left = left;
        newNode->middle = middle;
        newNode->right = right;
        newNode->noOperands = noOperands;

        newNode->nodeType = (char*)malloc(sizeof(char) * ( strlen(operation) + 1 ));
        strcpy(newNode->nodeType, operation);

		newNode->nodeNo = nodeCount++;

        return newNode;
    }

    void displayAST(node* root)
    {
		if(startFlag == 0) 
		{
			printf("==========================================================Abstract Syntax Tree============================================================\n\n");
			startFlag = 1;
		}
        if(root->noOperands == 3)
        {
            printf(" ( ");
            printf(" %s ", root->nodeType);
            displayAST(root->left);
            displayAST(root->middle);
            displayAST(root->right);
            printf(" ) ");
        }
        else if(root->noOperands == 2)
        {
            printf(" ( ");
            printf(" %s ", root->nodeType);
            displayAST(root->left);
            displayAST(root->middle);
            printf(" ) ");
        }
        else if(root->noOperands == 1)
        {
            printf(" ( ");
            printf(" %s ", root->nodeType);
            displayAST(root->left);
            printf(" ) ");
        }
        else if(root->noOperands == 0)
        {
            printf(" ( ");
            printf(" %s ", root->nodeType);
            printf(" ) ");
        }
    }

    void NumbertoString(int number, char * arr)
    {
        if(arr == NULL)
        {
            printf("some thing is wrong , allocate memory\n");
        }
        else
        {
            sprintf(arr, "%d", number);
        }
    }

    char * makeStr(int number, int flag)
    {
        char *A=(char *)malloc(sizeof(char)*10);
		NumbertoString(number,A);
		
		if(flag==1)
		{
				strcpy(tString, "T");
				strcat(tString, A);
				insertSymbol("ICGIdentifier", tString, -1,currentScope);
				return tString;
		}
		else
		{
				strcpy(lString, "L");
				strcat(lString, A);
				insertSymbol("ICGLabel", lString, -1,currentScope);
				return lString;
		}
    }

	void makeWhileQ(char *result, char *op1, char *op2, char *operator, int loopFlag)
	{
		threeAddressQueue[qIndex].Result = (char*)malloc(strlen(result)+1);
		threeAddressQueue[qIndex].operator = (char*)malloc(strlen(operator)+1);
		threeAddressQueue[qIndex].op1 = (char*)malloc(strlen(op1)+1);
		threeAddressQueue[qIndex].op2 = (char*)malloc(strlen(op2)+1);
		strcpy(threeAddressQueue[qIndex].Result, result);
		strcpy(threeAddressQueue[qIndex].op1, op1);
		strcpy(threeAddressQueue[qIndex].op2, op2);
		strcpy(threeAddressQueue[qIndex].operator,operator);
		threeAddressQueue[qIndex].Index = qIndex;
		threeAddressQueue[qIndex].loopFlag = loopFlag;
		qIndex++;
	}

    void makeQ(char *result, char *op1, char *op2, char *operator)
	{
		threeAddressQueue[qIndex].Result = (char*)malloc(strlen(result)+1);
		threeAddressQueue[qIndex].operator = (char*)malloc(strlen(operator)+1);
		threeAddressQueue[qIndex].op1 = (char*)malloc(strlen(op1)+1);
		threeAddressQueue[qIndex].op2 = (char*)malloc(strlen(op2)+1);
		strcpy(threeAddressQueue[qIndex].Result, result);
		strcpy(threeAddressQueue[qIndex].op1, op1);
		strcpy(threeAddressQueue[qIndex].op2, op2);
		strcpy(threeAddressQueue[qIndex].operator,operator);
		threeAddressQueue[qIndex].Index = qIndex;
		threeAddressQueue[qIndex].loopFlag = -1;
		qIndex++;
	}

    int isBinaryOperator(char * Op)
    {
		if((!strcmp(Op, "+")) || (!strcmp(Op, "*")) || (!strcmp(Op, "/")) || (!strcmp(Op, ">=")) || (!strcmp(Op, "<=")) || (!strcmp(Op, "<")) || (!strcmp(Op, ">")) || 
			(!strcmp(Op, "in")) || (!strcmp(Op, "==")) || (!strcmp(Op, "and")) || (!strcmp(Op, "or")))
		{
			return 1;
		}
		
		else 
		{
			return 0;
		}
    }

    void generateThreeAddressCode(node * root)
    {
        if(root == NULL)
		{
			return;
		}
        else if((!strcmp(root->nodeType, "If")) || (!strcmp(root->nodeType, "Elif")))
		{			
			switch(root->noOperands)
			{
				case 2 : 
				{
					int temp = labelIndex;
					generateThreeAddressCode(root->left);
					makeQ(makeStr(temp, 0), makeStr(root->left->nodeNo, 1), "-", "If False");
					labelIndex++;
					generateThreeAddressCode(root->middle);
					makeQ(makeStr(temp, 0), "-", "-", "Label");
					break;
				}
				case 3 : 
				{
					int temp = labelIndex;
					generateThreeAddressCode(root->left);
					makeQ(makeStr(temp, 0), makeStr(root->left->nodeNo, 1), "-", "If False");	
                    labelIndex=labelIndex+2;				
					generateThreeAddressCode(root->middle);
					makeQ(makeStr(temp+1, 0), "-", "-", "goto");
					makeQ(makeStr(temp, 0), "-", "-", "Label");
					generateThreeAddressCode(root->right);
					makeQ(makeStr(temp+1, 0), "-", "-", "Label");
					break;
				}
			}
			return;
		}
		else if(!strcmp(root->nodeType, "Else"))
		{
			generateThreeAddressCode(root->left);
			return;
		}
		else if(!strcmp(root->nodeType, "While"))
		{
			int temp = labelIndex;
			generateThreeAddressCode(root->left);
			makeQ(makeStr(temp, 0), "-", "-", "Label");		
			makeWhileQ(makeStr(temp+1, 0), makeStr(root->left->nodeNo, 1), "-", "If False", 0);								
			labelIndex+=2;			
			generateThreeAddressCode(root->middle);
			makeWhileQ(makeStr(temp, 0), "-", "-", "goto", 1);
			makeQ(makeStr(temp+1, 0), "-", "-", "Label"); 
			return;
		}
        else if(!strcmp(root->nodeType, "Next"))
		{
			generateThreeAddressCode(root->left);
			generateThreeAddressCode(root->middle);
			return;
		}
	    else if(!strcmp(root->nodeType, "BeginBlock"))
		{
			generateThreeAddressCode(root->left);
			generateThreeAddressCode(root->middle);		
			return;	
		}
		else if(!strcmp(root->nodeType, "EndBlock"))
		{
			switch(root->noOperands)
			{
				case 0 : 
				{
					break;
				}
				case 1 : 
				{
					generateThreeAddressCode(root->left);
					break;
				}
			}
			return;
		}
	    else if(isBinaryOperator(root->nodeType) == 1)
		{
			generateThreeAddressCode(root->left);
			generateThreeAddressCode(root->middle);
			char *X1 = (char*)malloc(sizeof(char)*10);
			char *X2 = (char*)malloc(sizeof(char)*10);
			char *X3 = (char*)malloc(sizeof(char)*10);
			
			strcpy(X1, makeStr(root->nodeNo, 1));
			strcpy(X2, makeStr(root->left->nodeNo, 1));
			strcpy(X3, makeStr(root->middle->nodeNo, 1));
			makeQ(X1, X2, X3, root->nodeType);
			free(X1);
			free(X2);
			free(X3);
			return;
		}
		else if(!strcmp(root->nodeType, "-"))
		{
			if(root->noOperands == 1)
			{
				generateThreeAddressCode(root->left);
				char *X1 = (char*)malloc(sizeof(char)* 10);
				char *X2 = (char*)malloc(sizeof(char)* 10);
				strcpy(X1, makeStr(root->nodeNo, 1));
				strcpy(X2, makeStr(root->left->nodeNo,1));
				makeQ(X1, X2, "-", root->nodeType);	
                free(X1);
                free(X2);
                return;
			}
			else
			{
				generateThreeAddressCode(root->left);
				generateThreeAddressCode(root->middle);
				char *X1 = (char*)malloc(sizeof(char)* 10);
				char *X2 = (char*)malloc(sizeof(char)* 10);
				char *X3 = (char*)malloc(sizeof(char)* 10);
			
				strcpy(X1, makeStr(root->nodeNo, 1));
				strcpy(X2, makeStr(root->left->nodeNo, 1));
				strcpy(X3, makeStr(root->middle->nodeNo, 1));

				makeQ(X1, X2, X3, root->nodeType);
				free(X1);
				free(X2);
				free(X3);
				return;
			
			}
		}
        else if(!strcmp(root->nodeType, "import"))
		{
			makeQ("-", root->left->nodeType, "-", "import");
			return;
		}
        else if(!strcmp(root->nodeType, "NewLine"))
		{
			generateThreeAddressCode(root->left);
			generateThreeAddressCode(root->middle);
			return;
		}
        else if(!strcmp(root->nodeType, "="))
		{
			generateThreeAddressCode(root->middle);
			makeQ(root->left->nodeType, makeStr(root->middle->nodeNo, 1), "-", root->nodeType);
			return;
		}
        else if(!strcmp(root->nodeType, "Func_Name"))
		{
			makeQ("-", root->left->nodeType, "-", "BeginF");
			generateThreeAddressCode(root->right);
			makeQ("-", root->left->nodeType, "-", "EndF");
			return;
		}
		else if(!strcmp(root->nodeType, "Func_Call"))
		{
			if(!strcmp(root->middle->nodeType, "Void"))
			{
				makeQ(makeStr(root->nodeNo, 1), root->left->nodeType, "-", "Call");
			}
			else
			{
				char * A = (char *)malloc(sizeof(char)* 10);
				char* token = strtok(root->middle->nodeType, ","); 
  			    int i = 0;
				while (token != NULL) 
				{
					i++; 
				    makeQ("-", token, "-", "Param"); 
				    token = strtok(NULL, ","); 
				}
				sprintf(A, "%d", i);
				makeQ(makeStr(root->nodeNo, 1), root->left->nodeType, A, "Call");				
				return;
			}
		}
        else if(root->noOperands == 0)
		{
			if(!strcmp(root->nodeType, "break"))
			{
				makeQ(makeStr(labelIndex, 0), "-", "-", "goto");
			}

			else if(!strcmp(root->nodeType, "pass"))
			{
				makeQ("-", "-", "-", "pass");
			}

			else if(!strcmp(root->nodeType, "return"))
			{
				makeQ("-", "-", "-", "return");
			}
			else 
			{
				makeQ(makeStr(root->nodeNo, 1), root->nodeType, "-", "=");
			}
            return ; 
		}
    }

	void printICG()
	{
		int i = 0;
		while(i < qIndex)
		{
			if(threeAddressQueue[i].Index != -1)
            {
                if(!strcmp(threeAddressQueue[i].operator, "="))
                {
                    printf("%s = %s\n", threeAddressQueue[i].Result, threeAddressQueue[i].op1);
                }
                else if(!strcmp(threeAddressQueue[i].operator, "If False"))
                {
                    printf("If False %s goto %s\n", threeAddressQueue[i].op1, threeAddressQueue[i].Result);
                }
                else if(!strcmp(threeAddressQueue[i].operator, "Label"))
                {
                    printf("%s: ", threeAddressQueue[i].Result);
                }
                else if(!strcmp(threeAddressQueue[i].operator, "goto"))
                {
                    printf("goto %s\n", threeAddressQueue[i].Result);
                }
                else if(!strcmp(threeAddressQueue[i].operator, "-"))
                {
                    if(!strcmp(threeAddressQueue[i].op2, "-"))
                    {
                        printf("%s = %s %s\n", threeAddressQueue[i].Result, threeAddressQueue[i].operator, threeAddressQueue[i].op1);
                    }
                    else
                    {
                        printf("%s = %s %s %s\n", threeAddressQueue[i].Result, threeAddressQueue[i].op1, threeAddressQueue[i].operator, threeAddressQueue[i].op2);
                    }
                }
                else if(!strcmp(threeAddressQueue[i].operator, "import"))
                {
                    printf("import %s\n", threeAddressQueue[i].op1);
                }
                else if(!strcmp(threeAddressQueue[i].operator, "="))
                {
                    printf("%s = %s\n", threeAddressQueue[i].Result, threeAddressQueue[i].op1);
                }
                else if(!strcmp(threeAddressQueue[i].operator, "BeginF"))
                {
                    printf("Begin Function %s\n", threeAddressQueue[i].op1);
                }
                else if(!strcmp(threeAddressQueue[i].operator,"EndF"))
                {
                    printf("End Function %s\n", threeAddressQueue[i].op1);
                }
                else if(!strcmp(threeAddressQueue[i].operator, "Call"))
                {
                    if(!strcmp(threeAddressQueue[i].op2, "-"))
                    {
                        printf("(%s)Call Function %s\n", threeAddressQueue[i].Result, threeAddressQueue[i].op1);
                    }
                    else
                    {
                        printf("(%s)Call Function %s, %s\n", threeAddressQueue[i].Result, threeAddressQueue[i].op1, threeAddressQueue[i].op2);
                        printf("Pop Params for Function %s, %s\n", threeAddressQueue[i].op1, threeAddressQueue[i].op2);
                    }
                }
                else if(!strcmp(threeAddressQueue[i].operator, "Param"))
                {
                    printf("Push Param %s\n", threeAddressQueue[i].op1);
                }
                else if(!strcmp(threeAddressQueue[i].operator, "return"))
                {
                    printf("return\n");
                }
                else if(isBinaryOperator(threeAddressQueue[i].operator) == 1)
                {
                    printf("%s = %s %s %s\n",threeAddressQueue[i].Result, threeAddressQueue[i].op1, threeAddressQueue[i].operator,threeAddressQueue[i].op2);
                }
                else
                {
                    printf("Something went wrong check pls\n");			
                }
            }
			i = i + 1;
		}
	}

    void deadCodeElimination()
    {
        int deadCodeExists = 1;
        while(deadCodeExists)
        {
            deadCodeExists = 0;
            for(int i=0;i<qIndex;i++)
            {
                if( !(strcmp(threeAddressQueue[i].operator,"Label") == 0) &&
                    !(strcmp(threeAddressQueue[i].operator,"goto") == 0)  &&
                    !(strcmp(threeAddressQueue[i].operator,"If False") == 0) &&
                    !(strcmp(threeAddressQueue[i].operator,"Call") == 0) &&
                    !(strcmp(threeAddressQueue[i].Result,"-") == 0) &&
					threeAddressQueue[i].Index != -2
                )
                {
                    int required = 0;
                    for(int j=i+1;j<qIndex;j++)
                    {
                        if( ( (strcmp(threeAddressQueue[j].op1,threeAddressQueue[i].Result) == 0) && threeAddressQueue[i].Index != -1) ||
                            ( (strcmp(threeAddressQueue[j].op2,threeAddressQueue[i].Result) == 0) && threeAddressQueue[i].Index != -1)  )
                            {
                                required = 1;
                                break;
                            }
                    }

                    if(!required && threeAddressQueue[i].Index != -1)
                    {
						threeAddressQueue[i - 1].Index = -1;
                        threeAddressQueue[i].Index = -1;
                        deadCodeExists = 1;
                    }
                }     
            }
        }
    }

	void loopUnroll()
	{
		optimisedThreeAddressQueue = (Quad*)malloc(qIndex * 2 * sizeof(Quad));

		int i = 0, qIndexOpt = 0, tempQIndex = 0, isRepeat = 0;
		
		while(i < qIndex)
		{
			if(threeAddressQueue[i].loopFlag == 0 && isRepeat == 0)
			{
				isRepeat += 1;
				tempQueue = (Quad*)malloc(qIndex * sizeof(Quad));
				optimisedThreeAddressQueue[qIndexOpt++] = threeAddressQueue[i];
			}
			else if(threeAddressQueue[i].loopFlag == 1 && isRepeat == 1)
			{
				isRepeat -= 1;
				for(int j = 0; j < tempQIndex; j++)
				{
					optimisedThreeAddressQueue[qIndexOpt++] = tempQueue[j];
				}
				free(tempQueue);
				tempQueue = NULL;
                tempQIndex = 0;
				optimisedThreeAddressQueue[qIndexOpt++] = threeAddressQueue[i];
			}
			else
			{
				if(isRepeat > 0)
				{
					if(threeAddressQueue[i].loopFlag == 0)
						isRepeat += 1;
					if(threeAddressQueue[i].loopFlag == 1)
						isRepeat -= 1;
					threeAddressQueue[i].Index = -2;
					optimisedThreeAddressQueue[qIndexOpt++] = threeAddressQueue[i];
					tempQueue[tempQIndex++] = threeAddressQueue[i];
					
					i++;
					continue;
				}
                optimisedThreeAddressQueue[qIndexOpt++] = threeAddressQueue[i];
			}
			i++;
		}

        copyFreeThreeAddressQueue = threeAddressQueue;
		threeAddressQueue = optimisedThreeAddressQueue;
        oldQIndex = qIndex; 
		qIndex = qIndexOpt;
	}

    void createError(int type, char* msg, int lineNo)
    {
        errors[ErrorIndex].type = type;
        errors[ErrorIndex].lineNo = lineNo;

        errors[ErrorIndex].msg = (char*)malloc(sizeof(char) * strlen(msg));
        strcpy(errors[ErrorIndex].msg, msg);

        ErrorIndex++;
    }

    void displayErrors()
    {
        for(int i = 0; i < ErrorIndex; i++)
        {
            printf(RED "%s %d\n" RESET, errors[i].msg, errors[i].lineNo);
        }
    }

    void deallocateMemory()
    {
        free(currentScope);
        free(tString);
        free(lString);

        for(int i=0;i < qIndex;i++)
        {
            if(i < oldQIndex)
            {
                free(copyFreeThreeAddressQueue[i].Result);
		        free(copyFreeThreeAddressQueue[i].operator);
		        free(copyFreeThreeAddressQueue[i].op1);
		        free(copyFreeThreeAddressQueue[i].op2);
            }
            
            free(threeAddressQueue[i].Result);
		    free(threeAddressQueue[i].operator);
		    free(threeAddressQueue[i].op1);
		    free(threeAddressQueue[i].op2);

        }

		for(int i = 0; i <= symbolCount; i++)
		{
            free(symbolTable[symbolCount].type);
            free(symbolTable[symbolCount].name);
            free(symbolTable[symbolCount].scope);
		}

        free(copyFreeThreeAddressQueue);
        free(threeAddressQueue);
    }

%}

%union 
{ 
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
%type <NODE> else_stmt while_stmt args call_params func_def func_call return_stmt 
%type <NODE> basic_stmt cmpd_stmt statements start_suite suite end_suite

%%

startparse: {init();} start  ENDFILE   {
                                if (isError == 0) {
									// No errors
									printSTable();
									displayAST($2);
									printf("\n\n\n====Intermediate code====\n\n");
									generateThreeAddressCode($2);
									printICG();
									printf("\n\n\n====Optimised intermediate code====\n\n");
									loopUnroll();
                                    deadCodeElimination();
									printICG();
                                    deallocateMemory();
									printf(GREEN "\n\nValid Python Syntax\n\n" RESET); 
                                 }
                                 else {
									// printf(RED "\nInvalid Python Syntax\n" RESET); 
									displayAST($2);
                                    printf("\n\n");
                                    displayErrors();
									printf("\n");
                                 }
								 exit(0);
                            } ;
start: NEWLINE start {$$=$2;} 
    | statements NEWLINE start {$$ = createOp("NewLine", 2, $1, $3,NULL); };
    | statements NEWLINE {$$=$1;};

constant: NUMBER {$$ = createOp($<text>1, 0, NULL, NULL, NULL); } 
        | STRING {$$ = createOp($<text>1, 0, NULL, NULL, NULL); };
term: ID {  
            if(searchSymbol($<text>1) < 0)
            {   
                createError(2, "NameError: Identifier is not declared in Line", yylineno);
                isError = 1;
            }
            $$ = createOp($<text>1, 0, NULL, NULL, NULL); 
        }
    | constant {$$ = $1;} ;
expressions: arith_expr {$$=$1;}| bool_expr {$$=$1;};
arith_expr: term {$$=$1;} 
            | arith_expr PL arith_expr {$$ = createOp("+", 2, $1, $3, NULL);}
			| arith_expr MN arith_expr {$$ = createOp("-", 2, $1, $3, NULL);}
			| arith_expr ML arith_expr {$$ = createOp("*", 2, $1, $3, NULL);}
			| arith_expr DV arith_expr {$$ = createOp("/", 2, $1, $3, NULL);}
            | MN arith_expr {$$ = createOp("-", 1, $2, NULL, NULL);}
            | OP arith_expr CP {$$ = $2;};
bool_term: TRUE {$$ = createOp("True", 0, NULL, NULL, NULL); }
          | FALSE {$$ = createOp("False", 0, NULL, NULL, NULL); }
          | arith_expr EE arith_expr {$$ = createOp("==", 2, $1, $3, NULL);}
          | bool_factor {$$ = $1;};
bool_factor: NOT bool_factor {$$ = createOp("!", 1, $2, NULL, NULL);}
          | OP bool_expr CP {$$ = $2;};  
bool_expr: arith_expr GT arith_expr {$$ = createOp(">", 2, $1, $3, NULL);}
          | arith_expr LT arith_expr {$$ = createOp("<", 2, $1, $3, NULL);}
          | arith_expr GE arith_expr {$$ = createOp(">=", 2, $1, $3, NULL);}
          | arith_expr LE arith_expr {$$ = createOp("<=", 2, $1, $3, NULL);}
		  | bool_term AND bool_term {$$ = createOp("AND", 2, $1, $3, NULL);}
		  | bool_term OR bool_term {$$ = createOp("or", 2, $1, $3, NULL);}
		  | bool_term {$$=$1;};

import_stmt: IMPORT ID {$$ = createOp("import", 1, createOp($<text>2, 0, NULL, NULL, NULL), NULL, NULL);};   
pass_stmt: PASS {$$ = createOp("pass", 0, NULL, NULL, NULL);};
break_stmt: BREAK {$$ = createOp("break", 0, NULL, NULL, NULL);};
return_stmt : RETURN {$$ = createOp("return", 0, NULL, NULL, NULL);};

assign_stmt: ID EQL expressions {
                                    insertSymbol("Identifier", $<text>1, yylineno, currentScope);
                                    $$ = createOp("=", 2, createOp($<text>1, 0, NULL, NULL, NULL), $3, NULL);
                                }
            | ID EQL func_call  {
                                    insertSymbol("Identifier", $<text>1, yylineno, currentScope);
                                    $$ = createOp("=", 2, createOp($<text>1, 0, NULL, NULL, NULL), $3, NULL);
                                }; 

if_stmt: IF bool_expr COLON start_suite %prec LOWER_THAN_EL {$$ = createOp("If", 2, $2, $4, NULL);}
       | IF bool_expr COLON start_suite elif_stmts {$$ = createOp("If", 3, $2, $4, $5);};
elif_stmts: ELIF bool_expr COLON start_suite elif_stmts {$$= createOp("Elif", 3, $2, $4, $5);}
          | else_stmt {$$= $1;};
else_stmt: ELSE COLON start_suite {$$ = createOp("Else", 1, $3, NULL, NULL);};

while_stmt: WHILE bool_expr COLON start_suite {$$ = createOp("While", 2, $2, $4, NULL);};

args_list: COMMA ID args_list | ;
args: ID args_list {$$ = createOp("TO DO", 0, NULL, NULL, NULL);} 
    | {$$ = createOp("Void", 0, NULL, NULL, NULL);};
call_list: COMMA term call_list | ;
call_params: term call_list {$$ = createOp("TO DO", 0, NULL, NULL, NULL);};

func_def: DEF ID OP args CP COLON {
                                    insertSymbol("Function", $<text>2, yylineno, currentScope);
                                    strcpy(currentScope, $<text>2);
                                  } 
          start_suite {
                        strcpy(currentScope, "Global");
                        $$ = createOp("Func_Name", 3, createOp($<text>2, 0, NULL, NULL, NULL), $4, $8);  
                      };
func_call: ID OP call_params CP {
                                    insertSymbol("Function", $<text>2, yylineno, currentScope);
                                    $$ = createOp("Func_Call", 2, createOp($<text>1, 0, NULL, NULL, NULL), $3, NULL);
                                } ;

basic_stmt: import_stmt {$$ = $1;}
            | pass_stmt {$$ = $1;}
            | break_stmt {$$ = $1;}
            | assign_stmt {$$ = $1;}
            | expressions {$$ = $1;}
            | return_stmt {$$ = $1;};


cmpd_stmt: if_stmt {$$ = $1;}
        | while_stmt {$$ = $1;};

statements: basic_stmt {$$ = $1;}
        | cmpd_stmt {$$ = $1;}
        | func_def {$$ = $1;}
        | func_call {$$ = $1;}
		| error NEWLINE {
                             yyclearin;
                             isError = 1;
                             $$ = createOp("SyntaxError", 0, NULL, NULL, NULL);
                         };

start_suite: basic_stmt {$$ = $1;} 
            | NEWLINE INDENT statements suite {$$ = createOp("BeginBlock", 2, $3, $4, NULL);};

suite: NEWLINE NOCHANGE statements suite {$$ = createOp("Next", 2, $3, $4, NULL);}
        | NEWLINE end_suite {$$ = $2;};

end_suite: DEDENT {$$ = createOp("EndBlock", 0, NULL, NULL, NULL);}
           | DEDENT statements {$$ = createOp("EndBlock", 1, $2, NULL, NULL);}
           | {$$ = createOp("EndBlock", 0, NULL, NULL, NULL); resetDepth();};

%%

int  yyerror(const char* text) {
    createError(1, "Syntax Error: Unexpected token at Line ", yylineno);
	// printf(RED "Syntax Error at Line %d\n   " RESET, yylineno);
}

int main() {
	yyparse();
}