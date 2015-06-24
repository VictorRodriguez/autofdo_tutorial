#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#include "matrix_multiplication.h"
#include "definitions.h"
#include "debug.h"

void multiply_matrix(int size){
	printf("Multiplying matrix of %dx%d\n", size, size);
	int c, d, k, sum = 0;
	int first[size][size], second[size][size];
	// int multiply[size][size];
	srand(time(NULL));

	//printf("Entering the elements of first matrix\n");

	for (c = 0; c < size; c++)
		for (d = 0; d < size; d++)
			first[c][d] = rand();

	//printf("Entering the elements of second matrix\n");

	for (c = 0; c < size; c++)
		for (d = 0; d < size; d++)
			second[c][d] = rand();

	for (c = 0; c < size; c++) {
	  for (d = 0; d < size; d++) {
	    for (k = 0; k < size; k++) {
	      sum = sum + first[c][k]*second[k][d];
	    }

	    // multiply[c][d] = sum;
	    sum = 0;
	  }
	}

	// printf("Product of entered matrices:-\n");

	for (c = 0; c < size; c++) {
	  for (d = 0; d < size; d++){
	    // printf("%d\t", multiply[c][d]);
	  }

	  // printf("\n");
	}
}

int main(){
	start();
	multiply_matrix(MATRIX_SIZE);
	stop();
	return 0;
}