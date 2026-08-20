#include "engine.h"
#include <stdio.h>
#include <string.h>


int main(int argc, char** argv) {
    // TODO: parse the arguments in argv. 
    // You can expect argv[1] to be the mode
    // You can expect argv[2] to be the filepath
    // You can expect argv[3] to be the target word
  

    if(argc != 4) {
        printf("Incorrect number of arguments. Expected: ./build/image_calc <MODE=count|instance> <input_file> <target_word>\n");
        return -1;
    }

    return 0;
    
}