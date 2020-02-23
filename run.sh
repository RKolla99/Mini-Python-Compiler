lex tokeniser.l
gcc lex.yy.c -ll
./a.out < test.py > output.txt
cat output.txt