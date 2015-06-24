#include <stdio.h>
#include <sys/time.h>
#include "debug.h"

struct timeval tm1;

void start(){
    gettimeofday(&tm1, NULL);
}

void stop(){
    struct timeval tm2;
    gettimeofday(&tm2, NULL);
    unsigned long long t = 1000 * (tm2.tv_sec - tm1.tv_sec) + (tm2.tv_usec - tm1.tv_usec) / 1000;
    printf("%llu ms\n", t);

}