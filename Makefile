CC=g++ -g -Wall
pyc.o: main.o pyyacc.o pylex.o
	@$(CC) -DEXTERNC -I/. pylex.o pyyacc.o main.o -o pyc.o
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
            
clean: 
	@rm -rf *.o
	@rm -rf *.h
	@rm -rf *.cxx
	@rm -rf *~ 
	@rm -rf *.output
	@rm -rf *.js

run:
	@./pyc.o palindromeString.py test.js
