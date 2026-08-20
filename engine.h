int search_count(char* filename, char* target);
struct count_result search_instance(char* filename, char* target);

struct count_result {
    int count;
    char** instances;
};