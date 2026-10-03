CC = gcc
CPPFLAGS = -I.
CFLAGS = -g -Wall -Wextra
LDLIBS = -lm

.PHONY: all clean

all: grep grep-openmp grep-parallel test test-openmp test-parallel

# Apply the required flags when compiling each parallel engine.
engine-parallel.o: CFLAGS += -pthread
engine-openmp.o: CFLAGS += -fopenmp

%.o: %.c
	$(CC) $(CPPFLAGS) $(CFLAGS) -c -o $@ $<

grep: grep.o engine.o
	$(CC) $(LDFLAGS) -o $@ $^ $(LDLIBS)

grep-parallel: grep.o engine-parallel.o
	$(CC) $(LDFLAGS) -pthread -o $@ $^ $(LDLIBS)

grep-openmp: grep.o engine-openmp.o
	$(CC) $(LDFLAGS) -fopenmp -o $@ $^ $(LDLIBS)

test: test.o engine.o
	$(CC) $(LDFLAGS) -o $@ $^ $(LDLIBS)

test-parallel: test.o engine-parallel.o
	$(CC) $(LDFLAGS) -pthread -o $@ $^ $(LDLIBS)

test-openmp: test.o engine-openmp.o
	$(CC) $(LDFLAGS) -fopenmp -o $@ $^ $(LDLIBS)

clean:
	rm -f *.o grep grep-parallel grep-openmp test test-parallel test-openmp