P="/usr/local/Cellar/flex/2.6.4/lib/"
CC=gcc

parser:
	bison -d bison.y
	flex lex.l
	$(CC) -o parser bison.tab.c lex.yy.c -L$(P) -lfl

clean:
	touch lex.yy.c
	touch bison.tab.c
	touch bison.tab.h
	touch parser
	rm lex.yy.c
	rm bison.tab.c
	rm bison.tab.h
	rm parser
