#include "bubble_sort.h"
#include "pi_calculation.h"
#include "matrix_multiplication.h"
#include "definitions.h"
#include "debug.h"

int all(){
	start();
	int array[ARRAY_LEN];
	generate_array(array, ARRAY_LEN);
	bubble_sort(array, ARRAY_LEN);
	calculate_pi_1(PI_LEN_MIN);
	calculate_pi_2(PI_LEN_MAX);
	multiply_matrix(MATRIX_SIZE);
	stop();
	return 0;
}
