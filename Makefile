CC=g++ -g -Wall
pyc.o: main.o pyyacc.o pylex.o dstruct.o
	@$(CC) -DEXTERNC -I/. pylex.o pyyacc.o dstruct.o main.o -o pyc.o
pylex.o: pyparser.l
	@flex pyparser.l
	@mv lex.yy.c pylex.cxx
	@$(CC) -c pylex.cxx -o pylex.o
pyyacc.o: pyparser.y
	@yacc -dvt pyparser.y
	@mv y.tab.c pyyacc.cxx
	@$(CC) -c pyyacc.cxx -o pyyacc.o
main.o: main.c
	@$(CC) -c main.c -o main.o
dstruct.o:dstruct.c
	@$(CC) -c dstruct.c -o dstruct.o
            
clean: 
	@rm -rf *.o
	@rm -rf y.tab.h
	@rm -rf *.cxx
	@rm -rf *~ 
	@rm -rf *.output
	@rm -rf *.js
	@rm -rf *.pyc

level1:
	@./pyc.o palindrome.py palindrome.js

level2:
	@./pyc.o kmp.py kmp.js
	
level3:
	@./pyc.o arithmetic.py arithmetic.js
    
test:
	@./pyc.o test.py test.js
