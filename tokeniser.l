%{
    #include <stdio.h>
    #include <string.h>
    #define STACK_SIZE 100

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

    int depth = 0;

%}

%option yylineno
whitespace [ ]
multiline_comment \'\'\'.+\'\'\'

%%

[\t]*   {
                    if(yyleng % 4 == 0) {
                        depth = indent_depth(yytext);
                        printf("Depth = %d", depth);

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
[_a-zA_Z][_a-zA_Z0-9]* {printf("ID\n");}
\"([^\"\n])*\" {printf("STRING\n");}
\'([^\'\n])*\' {printf("STRING\n");}
"#"([a-z]|[0-9]|[A-Z]|" ")* {} 
{whitespace} {}

"\n" {printf("NEWLINE\n");}
%%


int main() {
    yylex();
    return 0;
}