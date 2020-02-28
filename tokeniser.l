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
trip_squote '''

%%
\n[\t]* {
            depth = indent_depth(yytext);
            //return Depth = %d", depth);

            if (depth == 0) {
                return NEWLINE;
            }

            if(depth < top()) {
                while(depth < top())
                    pop();
                
                // printf("Depth = %d", depth);
                if(depth != top())
                    handle_error(yylineno);


                return DEDENT;
            }

            if(depth > top()) {
                push(depth);

                return INDENT;
            }
            
        }
"import" {return IMPORT;}
"def" {return DEF;}
"for" {return FOR;}
"while" {return WHILE;}
"if" {return IF;}
"elif" {return ELIF;}
"else" {return ELSE;}
"in" {return IN;}
"is" {return IS;}
"or" {return OR;}
"and" {return AND;}
"not" {return NOT;}
"pass" {return PASS;}
"break" {return BREAK;}
"continue" {return CONTINUE;}
"return" {return RETURN;}
":" {return COLON;}
">" {return GT;}
"<" {return LT;}
">=" {return GE;}
"<=" {return LE;}
"==" {return EE;}
"!=" {return NE;}
"True" {return TRUE;}
"False" {return FALSE;}
"None" {return NONE;}
"+" {return PL;}
"-" {return MN;}
"*" {return ML;}
"/" {return DV;}
"%" {return MOD;}
"^" {return XOR;}
"&" {return BAND;}
"|" {return BOR;}
"(" {return OP;}
")" {return CP;}
"[" {return OB;}
"]" {return CB;}
"," {return COMMA;}
"=" {return EQL;}
[0-9]+ {return NUMBER;}
[_a-zA_Z][_a-zA_Z0-9]*  {

                            int check = searchSymbol(yytext);
                            // return Check - %d\n", check);

                            if(check == -1)  {
                                insertSymbol(yytext, yylineno, top());
                            }
                            else {
                                modifySymbol(check, yylineno);
                            }
                            
                            return ID;
                        }
\"([^\"\n])*\" {return STRING;}
\'([^\'\n])*\' {return STRING;}
"#".* {}
{trip_squote}[^{trip_squote}]*{trip_squote} {}
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