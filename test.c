#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "engine.h"


int test_count1() {
    int res = search_count("data/small.txt", "the");
    
    if(res != 2) {
        return 0;
    }

    res = search_count("data/small.txt", "dog");

    if(res != 1) {
        return 0;
    }

    res = search_count("data/small.txt", "doggy");

     if(res != 0) {
        return 0;
    }
    return 1;
}

int test_count2() {
    int res = search_count("data/warnpeace.txt", "help");
    if(res != 207) {
        return 0;
    }

    res = search_count("data/lesmis.txt", "the");

    if(res != 48381) {
        return 0;
    }

    res = search_count("data/odyssey.txt", "Telemachus");
    if(res != 272) {
        return 0;
    }
    return 1;
}

int test_instance1() {
    struct count_result res = search_instance("data/small.txt", "the");
    
    if(res.count != 2) {
        return 0;
    }

    if(strcmp(res.instances[0],"the quick") != 0) {
        printf("%s != %s\n", res.instances[0], "the quick\n");
        return 0;
    }
    if(strcmp(res.instances[1],"the lazy dog") != 0) {
        printf("%s != %s\n", res.instances[1], "the lazy dog\n");
        return 0;
    }
    return 1;
}

int test_instance2() {
    struct count_result res = search_instance("data/warnpeace.txt", "help");
    if(res.count != 207) {
        return 0;
    }

    res = search_instance("data/lesmis.txt", "the");

    if(res.count != 48381) {
        return 0;
    }

    res = search_instance("data/odyssey.txt", "Telemachus");
    if(res.count != 272) {
        return 0;
    }
    return 1;
}


int run_test(char * test_name, int (*test_func)()) {
    int test_res = test_func();
    printf("Test %-25s: %d/1\n", test_name, test_res);
    return test_res;
}

int main(int argc, char **argv){
    if(argc != 2) {
        printf("ERROR: expected format ./test_one <test_num>\n");
        return -1;
    }
    int passed = 0;
    int test_num = atoi(argv[1]);
    
    char *test_list[] = {"Test Count 1","Test Count 2", "Test Instance 1", "Test Instance 2"};
    int (*test_func[])() = {&test_count1, &test_count2, &test_instance1, &test_instance2};

    passed += run_test(test_list[test_num], test_func[test_num]);
    int tests_ran = 1;

    printf("Total: %d/%d\n", passed, tests_ran);
    return passed;
}