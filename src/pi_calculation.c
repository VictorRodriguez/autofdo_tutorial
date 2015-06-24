#include <stdio.h>
#include <math.h>
#include "pi_calculation.h"
#include "definitions.h"
#include "debug.h"

void calculate_pi_1(int size){
	printf("Calculating PI method 1 with %d digits \n", size);
	int i, j, k;
	int len = floor(10 * size/3) + 1;
	int A[len];

	for(i = 0; i < len; ++i) {
	A[i] = 2;
	}

	int nines    = 0;
	// int predigit = 0;

	for(j = 1; j < size + 1; ++j) {        
		int q = 0;

		for(i = len; i > 0; --i) {
			int x  = 10 * A[i-1] + q*i;
			A[i-1] = x % (2*i - 1);
			q = x / (2*i - 1);
		}

		A[0] = q%10;
		q    = q/10;

		if (9 == q) {
		  ++nines;
		}
		else if (10 == q) {
		  //printf("%d", predigit + 1);

		  for (k = 0; k < nines; ++k) {
		    //printf("%d", 0);
		  }
		  // predigit = 0;
		  nines = 0;
		}
		else {
		  //printf("%d", predigit);
		  // predigit = q;

		  if (0 != nines) {    
		    for (k = 0; k < nines; ++k) {
		      //printf("%d", 9);
		    }

		    nines = 0;
		  }
		}
	}
	//printf("%d", predigit);
}

void calculate_pi_2(int size){
	printf("Calculating PI method 2 with %d digits\n", size);
	int r[size + 1];
    int i, k;
    int b, d;
    // int c = 0;

    for (i = 0; i < size; i++) {
        r[i] = 2000;
    }

    for (k = size; k > 0; k -= 14) {
        d = 0;

        i = k;
        for (;;) {
            d += r[i] * 10000;
            b = 2 * i - 1;

            r[i] = d % b;
            d /= b;
            i--;
            if (i == 0) break;
            d *= i;
        }
        // printf("%.4d", c + d / 10000);
        // c = d % 10000;
    }

    //printf("\n");

}


int main(){
	start();
	calculate_pi_1(PI_LEN_MIN);
	calculate_pi_2(PI_LEN_MAX);
	stop();
	return 0;
}