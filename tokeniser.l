%{
    #include <stdio.h>
    #include <string.h>
    #include <stdlib.h>
    #define STACK_SIZE 100

    typedef struct symbol {
        char* name;
        int decLine;
        int lastLine;
        int scope;
    } symbol;

    static symbol symbolTable[500];

    static int symbolCount = -1;

    static int stack_level = -1, error_number = -1, indent_stack[STACK_SIZE], errors[100];

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

    static void push(int level) {
        if (++stack_level < STACK_SIZE) 
            indent_stack[stack_level] = level;
        else {
            printf("Maximum indent level reached: Stack overflow");
            exit(0);
        }
    }

    static int pop() {
        if(stack_level > -1)
            return indent_stack[stack_level--];
        else {
            printf("Mismatched indents");
            exit(0);
        }
    }

    static int top() {
        if (stack_level > -1)
            return indent_stack[stack_level];
        else
            return 0;
    }

    static int indent_depth(char* indents) {
        return strlen(indents);
    }

    static void handle_error(int lineno) {
        errors[++error_number] = lineno;
    }

    static void printErrors() {
        for (int i = 0; i <= error_number; i++) {
            printf("Syntax error in line %d\n", errors[i]);
        }
    }

    int depth = 0;

%}

%option yylineno
whitespace [ ]
multiline_comment \'\'\'.+\'\'\'

%%
\n[\t]* {
            printf("NEWLINE\n");
            depth = indent_depth(yytext);
            // printf("Depth = %d", depth);

            if(depth < top()) {
                while(depth < top())
                    pop();
                
                printf("DEDENT\n");
            }

            if(depth > top()) {
                push(depth);

                printf("INDENT\n");
            }
        }
"import" {printf("IMPORT\n");}
"def" {printf("DEF\n");}
"for" {printf("FOR\n");}
"while" {printf("WHILE\n");}
"if" {printf("IF\n");}
"elif" {printf("ELIF\n");}
"else" {printf("ELSE\n");}
"in" {printf("IN\n");}
"is" {printf("IS\n");}
"or" {printf("OR\n");}
"and" {printf("AND\n");}
"not" {printf("NOT\n");}
"pass" {printf("PASS\n");}
"break" {printf("BREAK\n");}
"continue" {printf("CONTINUE\n");}
"return" {printf("RETURN\n");}
":" {printf("COLON\n");}
">" {printf("GT\n");}
"<" {printf("LT\n");}
">=" {printf("GE\n");}
"<=" {printf("LE\n");}
"==" {printf("EE\n");}
"!=" {printf("NE\n");}
"True" {printf("TRUE\n");}
"False" {printf("FALSE\n");}
"+" {printf("PL\n");}
"-" {printf("MN\n");}
"*" {printf("ML\n");}
"/" {printf("DV\n");}
"(" {printf("OP\n");}
")" {printf("CP\n");}
"[" {printf("OB\n");}
"]" {printf("CB\n");}
"," {printf("COMMA\n");}
"=" {printf("EQL\n");}
[0-9]+ {printf("NUMBER\n");}
[_a-zA_Z][_a-zA_Z0-9]*  {
                            printf("ID\n");

                            int check = searchSymbol(yytext);
                            // printf("Check - %d\n", check);

                            if(check == -1)  {
                                insertSymbol(yytext, yylineno, top());
                            }
                            else {
                                modifySymbol(check, yylineno);
                            }
                        }
\"([^\"\n])*\" {printf("STRING\n");}
\'([^\'\n])*\' {printf("STRING\n");}
"#"([a-z]|[0-9]|[A-Z]|" ")* {}
{multiline_comment} {}
{whitespace} {}

.   {
        // printf("Syntax error in line %d\n", yylineno);
        handle_error(yylineno);
    }

%%


int main() {
    push(1);
    yylex();
    printSTable();
    printErrors();
    return 0;
}