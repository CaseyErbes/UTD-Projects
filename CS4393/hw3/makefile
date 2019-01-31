INC=/usr/local/ssl/include/
LIB=/usr/local/ssl/lib/

guess-key:
	gcc -I$(INC) -L$(LIB) -o guess-key guess-key.c -lcrypto -ldl

clean:
	touch guess-key
	rm guess-key
