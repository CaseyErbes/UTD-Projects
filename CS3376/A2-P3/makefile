CC=gcc
CFLAGS=
DEPS=
MYFILE=myFile.o

%.o: %.c $(DEPS)
	$(CC) -c -o $@ $< $(CFLAGS)

myFile: $(MYFILE)
	$(CC) -o $@ $^ $(CFLAGS)
