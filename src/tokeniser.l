%{
    #include <stdio.h>
    #include <string.h>
    #include <stdlib.h>
    #include "y.tab.h"
    #define STACK_SIZE 100

    int depth = 0;
    static int stack_level = -1, indent_stack[STACK_SIZE];
    int startFlag = 1, lastDedent = 1, isError = 0;

    static void push(int level) {
        if (++stack_level < STACK_SIZE) 
            indent_stack[stack_level] = level;
        else {
            printf("Maximum indent level reached: Stack overflow");
            exit(0);
        }
    }

    int pop() {
        if(stack_level > -1)
            return indent_stack[stack_level--];
        else {
            printf("Mismatched indents");
            exit(0);
        }
    }

    int top() {
        if (stack_level > -1)
            return indent_stack[stack_level];
        else
            return 0;
    }

    static int indent_depth(char* indents) {
        return strlen(indents);
    }

    static void print_token(const char *X)
 	{
 		if(startFlag)
 		{
 			printf("\n---------------------------------Token Sequence--------------------------\n1 ");
 			startFlag=0;
 		}
 		
 		if(strcmp(X, "NEWLINE")==0)
 		{
 			printf("%s\n%d ", X, yylineno);
 		}
		else
		{
			printf("%s ", X);	
		}
 	}
%}

%option yylineno
whitespace [ ]
trip_squote '''

%%
[\t]*   {
            depth = indent_depth(yytext);
            //printf("Depth = %d\n", depth);

            if(depth < top()) {
                while(depth < top())
                    pop();
                
                yylval.depth = depth;
                // printf("Depth = %d", depth);
                // if(depth != top())
                //     handle_error(yylineno);

                print_token("DEDENT ");
                return DEDENT;
            }

            if(depth == top()) {
                yylval.depth = depth;
                print_token("NOCHANGE ");
                return NOCHANGE;
            }

            if(depth > top()) {
                push(depth);
                yylval.depth = depth;
                print_token("INDENT ");
                return INDENT;
            }
        }
"import" {print_token("IMPORT "); return IMPORT;}
"while" {print_token("WHILE "); return WHILE;}
"if" {print_token("IF "); return IF;}
"elif" {print_token("ELIF "); return ELIF;}
"else" {print_token("ELSE "); return ELSE;}
"in" {print_token("IN "); return IN;}
"or" {print_token("OR "); return OR;}
"and" {print_token("AND "); return AND;}
"not" {print_token("NOT "); return NOT;}
"pass" {print_token("PASS "); return PASS;}
"break" {print_token("BREAK "); return BREAK;}
"return" {print_token("RETURN "); return RETURN;}
"def" {print_token("DEF"); return DEF;}
":" {print_token("COLON "); return COLON;}
">" {print_token("GT "); return GT;}
"<" {print_token("LT "); return LT;}
">=" {print_token("GE "); return GE;}
"<=" {print_token("LE "); return LE;}
"==" {print_token("EE "); return EE;}
"!=" {print_token("NE "); return NE;}
"True" {print_token("TRUE "); return TRUE;}
"False" {print_token("FALSE "); return FALSE;}
"+" {print_token("PL "); return PL;}
"-" {print_token("MN "); return MN;}
"*" {print_token("ML "); return ML;}
"/" {print_token("DV "); return DV;}
"(" {print_token("OP "); return OP;}
")" {print_token("CP "); return CP;}
"[" {print_token("OB "); return OB;}
"]" {print_token("CB "); return CB;}
"=" {print_token("EQL "); return EQL;}
"," {print_token("COMMA"); return COMMA;}
[0-9]+ {print_token("NUMBER "); yylval.num = strdup(yytext); return NUMBER;}
[_a-zA_Z][_a-zA_Z0-9]*  {print_token("ID "); yylval.text = strdup(yytext); return ID;}
\"([^\"\n])*\" {print_token("STRING "); yylval.str = strdup(yytext); return STRING;}
\'([^\'\n])*\' {print_token("STRING "); yylval.str = strdup(yytext); return STRING;}
"#".* {}
{trip_squote}[^{trip_squote}]*{trip_squote} {}
{whitespace} {}
"\n" {print_token("NEWLINE"); return NEWLINE;}
<<EOF>> {print_token("ENDFILE\n"); return ENDFILE;}

.   {
         isError = 1;
         yyerror();
        // handle_error(yylineno);
    }

%%


// int main() {
//     push(1);
//     yylex();
//     printErrors();
//     return 0;
// }