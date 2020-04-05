%{
    #include <stdio.h>
    #include <string.h>
    #include <stdlib.h>
    #include "y.tab.h"
    #define STACK_SIZE 100

    int depth = 0;
    static int stack_level = -1, indent_stack[STACK_SIZE];

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
%}

%option yylineno
whitespace [ ]
trip_squote '''

%%
[\t]*   {
            depth = indent_depth(yytext);
            printf("Depth = %d", depth);

            if(depth < top()) {
                while(depth < top())
                    pop();
                
                // printf("Depth = %d", depth);
                // if(depth != top())
                //     handle_error(yylineno);

                printf("DD");
                return DEDENT;
            }

            if(depth == top()) {
                printf("ND");
                return NOCHANGE;
            }

            if(depth > top()) {
                push(depth);
                printf("ID");
                return INDENT;
            }
            
        }
"import" {return IMPORT;}
"while" {return WHILE;}
"if" {return IF;}
"elif" {return ELIF;}
"else" {return ELSE;}
"in" {return IN;}
"or" {return OR;}
"and" {return AND;}
"not" {return NOT;}
"pass" {return PASS;}
"break" {return BREAK;}
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
"+" {return PL;}
"-" {return MN;}
"*" {return ML;}
"/" {return DV;}
"(" {return OP;}
")" {return CP;}
"[" {return OB;}
"]" {return CB;}
"=" {return EQL;}
[0-9]+ {yylval.num = strdup(yytext); return NUMBER;}
[_a-zA_Z][_a-zA_Z0-9]*  {yylval.text = strdup(yytext); return ID;}
\"([^\"\n])*\" {yylval.str = strdup(yytext); return STRING;}
\'([^\'\n])*\' {yylval.str = strdup(yytext); return STRING;}
"#".* {}
{trip_squote}[^{trip_squote}]*{trip_squote} {}
{whitespace} {}
"\n" {return NEWLINE;}
<<EOF>> {return ENDFILE;}

.   {
        printf("Syntax error in line %d\n", yylineno);
        // handle_error(yylineno);
    }

%%


// int main() {
//     push(1);
//     yylex();
//     printErrors();
//     return 0;
// }