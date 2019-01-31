These flex and bison files were written, compiled, and run on a macOS environment, using a flex library installed with homebrew.

In order to compile on my environment, I run the following code:
	bison -d bison.y
	flex lex.l
	gcc -o parser bison.tab.c lex.yy.c -L"/usr/local/Cellar/flex/2.6.4/lib/" -lfl

The first line compiles the bison.y file into the bison.tab.c and bison.tab.h files.
The second line compiles the lex.l file into the lex.yy.c file.
The Third line compiles the lex.yy.c file into an executable called lex.
Since the fl library is not readily available in macOS systems, the installed flex library must be linked with the -L argument. Only then may the fl library be linked with the -l argument.

Another alternative on macOS systems that works is:
	bison -d bison.y
	flex lex.l
	gcc -o parser bison.tab.c lex.yy.c -ll

This just links to the l library provided by the macOS, and works just as well.

On Windows systems, it should be sufficient to run the following code to compile the program:
	bison -d bison.y
	flex lex.l
	gcc -o parser bison.tab.c lex.yy.c -lfl

Finally, to run the lex executable, run the following line, which should work across all platforms.
	./parser < (text_file_name)
	EX: ./parser < sample.txt

Running this will print out token/lexeme pairs, with tokens on the left and lexemes on the right.
