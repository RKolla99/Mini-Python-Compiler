lex tokeniser.l
yacc -d parser.y
gcc lex.yy.c y.tab.c -ll
./a.out < test.py > output.txt
cat output.txt