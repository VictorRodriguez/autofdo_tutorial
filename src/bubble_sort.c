#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include "bubble_sort.h"
#include "definitions.h"
#include "debug.h"

void bubble_sort (int *a, int n) {
    int i, t, s = 1;
    while (s) {
        s = 0;
        for (i = 1; i < n; i++) {
            if (a[i] < a[i - 1]) {
                t = a[i];
                a[i] = a[i - 1];
                a[i - 1] = t;
                s = 1;
            }
        }
    }
}

void generate_array(int *buffer, int len){
	printf("Bubble sorting array of %d elements\n", len);
	srand(time(NULL));
	int i;
	for(i = 0; i < len; ++i)
		buffer[i] = rand();
	bubble_sort(buffer, len);
}

int main(){
    start();
    int array[ARRAY_LEN];
    generate_array(array, ARRAY_LEN);
    bubble_sort(array, ARRAY_LEN);
    stop();
    return 0;
}