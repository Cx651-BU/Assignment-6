# A6 - Parallel Word Search

In this week’s assignment you will build a word-searching utility that reads in large files and searches for occurrences of a word. 

To speed-up the program’s execution you will create multi-threaded workers, each responsible for disjoint portions of the file, implementing data parallelism in practice! 

Certain aspects of the worker’s tasks—reading the file –will be IO bound allowing us to measure concurrency in practice. 

You will also need to use mutexes or strategize about shared data to carefully control your worker threads accesses to shared data structures and avoid data races! 


## Part 1: Serial Word Search

First, let's implement two word searching utilities:
- search_count: returns the integer count of all occurrences of the target word in the file 
- search_instance: returns the count and an array of string "instances" of the word. The string will be the string line where the word was found.

`search_instance` returns a `struct count_result`. The count field stores the integer count of found words. The `instances` array is a pointer to the first element of an array of c strings. Each element of this array is a **whitespace stripped** string of the entire line which contained the target word.

```c
struct count_result {
    int count;
    char** instances;
};
```

For example, on file:

```
the quick
brown fox
jumps over
the lazy dog
```

`search_instance(file, "the")` should return a struct containing:

```
2
["the quick","the lazy dog"]
```


> [!IMPORTANT]
> - Task: Implement `engine.c` and `grep.c` to take in an input filepath and a target word and report the number of occurrences of each word.
>   - At this point you should be able to run commands in the form:  `./grep instance data/small.txt the` to count the instances of the word "the" for example.

The output of your grep command should look like the following:
```
$ ./grep instance data/small.txt the
Found: 2 of the in data/small.txt
res.instances[0]: the quick
res.instances[1]: the lazy dog
```

Once you have completed this step, you should be able to pass `./test 0`, `./test 1`, `./test 2`, `./test 3`:

```
$ make test
gcc -c -o test.o test.c -I. -lm -g 
gcc -c -o engine.o engine.c -I. -lm -g 
gcc -o test test.o engine.o -I. -lm -g 
$ ./test 0
Test Test Count 1             : 1/1
Total: 1/1
$ ./test 1
Test Test Count 2             : 1/1
Total: 1/1
$ ./test 2
Test Test Instance 1          : 1/1
Total: 1/1
$ ./test 3
Test Test Instance 2          : 1/1
Total: 1/1
```

### Measuring and Timing Word Search

Let's time our word search. How long does it take to complete?

```
time ./grep instance data/warnpeace.txt help
```

> [!IMPORTANT]
> Describe the output of the `time` command in `questions.txt`. Label your answer `(1)`.


## Part 2: Parallel Word Search

Now we will be implementing engine-parallel.c with POSIX thread API. Our input file is quite long. We will be using **data parallelism** to have a worker thread each work on a chunk of a file, all in parallel.


You will want to use `pthread_create` to create your worker threads:
``` c
pthread_create(
    &threads[i], //pointer to pthread_t identifier
    NULL, //attributes, set to NULL
    count_worker, //function where worker starts execution
    &args[i] //pointer to argument structure
);
```

`pthread_create` needs a reference to a function where execution will start. Likely you will need two of these worker functions (one for count and one for instance):

```c

void *instance_worker(void *arg) {
    struct worker_args *args = arg;
}

void *count_worker(void *arg) {
    struct worker_args *args = arg;
}

```

You will want to pass each worker thread arguments. A useful argument struct could resemble the following:
``` c
struct worker_args {
    char *filename;
    char *target;

    long start; //start of the chunk to process
    long end; //end of the chunk to process

};
```

You will want to use `pthread_join` to wait for your worker threads to complete and collect results.

```c
pthread_join(threads[i], NULL);
```

> [!IMPORTANT]
> - Task: Implement `engine-parallel.c` to take in an input filepath and a target word and report the number of occurrences of each word with multiple workers and data parallelism!

### Preventing Data Races

You may notice that your engine-parallel.c sometimes reports an incorrect count. Why is this?

> [!IMPORTANT]
> Structure your code to prevent data races. Either use a `mutex` or restructure your code to avoid shared global variables.
> - Task: In `questions.txt` explain if you encountered any data races and how you structured your code to avoid them. Label your answer `(2)`.

At this point, running `make test-parallel` and `./test-parallel 0`,`./test-parallel 1`,`./test-parallel 2`,`./test-parallel 3` should all pass.

### Measuring and Timing Word Search

Let's time our parallel word search. How long does it take to complete?
To pass this task it will need to be *faster* that your serial implementation!

```
time ./grep-parallel instance data/warnpeace.txt help
```

## Part 3: Parallelization Libraries (OpenMP)

There was a lot of overhead that we as programmers had to do to parallelize our previous code! We now ask ourselves-- is there an easier way?
A lot of talented programmers have spent lots of time and effort creating existing libraries that allow us to parallelize our code in an easier manner that can even be **faster!**

Let's try one popular C parallelization library: OpenMP. 

**OpenMP (Open Multi-Processing)** is an application programming interface that lets you write parallel code for shared-memory computers.

When you compile an OpenMP program, you will need to use the `-fopenmp` flag.

```make
gcc -fopenmp main.c -o program
```

The following code adds parallelism with a **parallel for** compiler directive. 
```c
#include <iostream>
#include <omp.h>

int main() {
    const int N = 100;
    int data[N];

    // Distributes the 100 iterations among available CPU threads
    #pragma omp parallel for
    for (int i = 0; i < N; i++) {
        data[i] = i * 2;
    }

    return 0;
}
```

A good starting place might be to structure your code as follows:
```c
    #pragma omp parallel for num_threads(thread_count)
    for (int i = 0; i < thread_count; i++) {
        // TODO: calculate start/end based on i and size of the file
        partial[i] = search_instance_chunk(filename,target,start,end);
    }
```

> [!IMPORTANT]
> - Task: Implement `engine-openmp.c` using a parallel for loop and OpenMP. Again, remember to avoid data races.
>   - Also ensure that your parallel implementation with openmp is faster than your serial solution.
> - Task: In `questions.txt` explain how your parallel solution implemented in openmp differs from using pthread POSIX api directly. Label your answer `(3)`.

At this point, running `make test-openmp` and `./test-openmp 0`,`./test-openmp 1`,`./test-openmp 2`,`./test-openmp 3` should all pass.

Also, running `source test.sh` should pass.
When you are happy with your score, submit all files to Gradescope.

## Timing on the Autograder

The autograder will benchmark your two parallel implementations against your serial implementation.
The autograder will test a random 1GB text file instead of warnpeace.txt.

If you want to test this yourself locally: 
```
head -c 1073741824 /dev/urandom > data/bigfile.txt
```

Then, use `data/bigfile.txt` as the file you benchmark your two implementations with.
You can time your program with the Linux `time` utility or an equivalent.

## Submitting on Gradescope

To submit on Gradescope, submit all the files in this directory to the assignment upload.

You do not need to upload the `data/` subdirectory.

**DO NOT upload a zip.** Use Shift to select all the files in your assignment directory instead.

Note: To download files from google colab, navigate to the `Assignment-6` directory that should be saved in your **Google Drive**. (Assuming you did all your work in `/content/drive/MyDrive/Assignment-6`). Clicking the three vertical dots shows a "download" option that will download all files to your local computer for upload to gradescope.

You should see the autograder run and report a score. Ensure that you are happy with this score! Feel free to resubmit as many times as you wish before the deadline.
