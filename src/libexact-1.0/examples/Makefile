CC = c99
CFLAGS = -O3 -I ..

all: example-first example-partition example-sudoku

example-first: example-first.o ../libexact.a
	$(CC) -o example-first example-first.o ../libexact.a

example-partition: example-partition.o ../libexact.a
	$(CC) -o example-partition example-partition.o ../libexact.a

example-sudoku: example-sudoku.o ../libexact.a
	$(CC) -o example-sudoku example-sudoku.o ../libexact.a

clean:
	rm -f *.o *~ example-first example-partition example-sudoku
