lex src/tokeniser.l
yacc -d src/parser.y
gcc lex.yy.c y.tab.c -ll
# ./a.out < test/test2.py > output.txt
# cat output.txt