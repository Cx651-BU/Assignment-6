all: grep grep-openmp grep-parallel test test-openmp test-parallel

CC=gcc
CFLAGS=-I. -lm -g 

%.o: %.c 
	$(CC) -c -o $@ $< $(CFLAGS)

grep: grep.o engine.o 
	$(CC) -o $@ $^ $(CFLAGS)

grep-parallel: grep.o engine-parallel.o 
	$(CC) -Wextra -pthread -o $@ $^ $(CFLAGS)

grep-openmp: grep.o engine-openmp.o 
	$(CC) -Wextra -pthread -fopenmp -o $@ $^ $(CFLAGS)

test: test.o engine.o
	$(CC) -o $@ $^ $(CFLAGS)

test-parallel: test.o engine-parallel.o 
	$(CC) -Wextra -pthread -o $@ $^ $(CFLAGS)

test-openmp: test.o engine-openmp.o 
	$(CC) -Wextra -pthread -fopenmp -o $@ $^ $(CFLAGS)

clean:
	rm -f *.o
	rm -f test
	rm -f grep