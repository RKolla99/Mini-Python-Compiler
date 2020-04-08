lex src/tokeniser.l
yacc -d src/parser.y
gcc lex.yy.c y.tab.c -ll -ly
# ./a.out < test/test.py > output.txt
# cat output.txt