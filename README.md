AutoFDO tutorial
================

This package will help you understand and automate the process of using feedback driven optimizations, the tutorial has been divided in three sections:

## 1. Basic understanding

In this repository you will find a `sort.c` file that contains a sorting algorithm to start using optimizations, then you will need to read our document in https://gcc.gnu.org/wiki/AutoFDO/Tutorial and follow the steps to compare different types of optimizations:

1. GCC normal optimization (just add the -O flag to the gcc command)
2. FDO (By executing the instrumented binary, it will output data to a profile file)
3. AutoFDO (By using perf, it will sample the hardware events to create a profile file)
 
You can read more information about using optimization flags in here https://gcc.gnu.org/onlinedocs/gcc/Optimize-Options.html

## 2. Different use cases

You might will be willing to optimize a package that can include different binaries, which may result in multiple binaries, so we included an example in this tutorial. Every binary contains different algorithms with a timing measure that prints at the end of the execution so you won't need to implement any time mesurement tool.

#### GCC normal optimization

If you want to know how much performance is imporved by FDO, compile them with `$ make release` This will enable the `-O3` flag.

Execute every binary to know how much they delay.

#### Normal FDO

For this case you will need to compile all the binaries with the debug symbols and the `-fprofile-generate` flag to keep track of the execution feedback:

    $ gcc -g3 -Iinclude -lm -o bubble_sort src/bubble_sort.c src/debug.c -fprofile-generate
    $ gcc -g3 -Iinclude -lm -o matrix_multiplication src/matrix_multiplication.c src/debug.c -fprofile-generate
    $ gcc -g3 -Iinclude -lm -o pi_calculation src/pi_calculation.c src/debug.c -fprofile-generate
    
Then execute each binary to get the feedback:

    $ ./bubble_sort
    $ ./matrix_multiplication
    $ ./pi_calculation
    
Then recompile again with the `-fprofile-use` flag and the optimization enabled (`-O3`)

In case that you want to compile using `$ make release` you will need to change the `RELEASEFLAGS` variable to include `-fprofile-use=*.gcda` to use all the profile files

Execute the binaries again to measure the time and compare with other optimization methods.

#### AutoFDO

The first thing you do after downloading a source code is compiling, so go ahead and execute:

    $ make

Then we have included a proccess that generates the profiles for you. We are taking advantage of a perf wrapper named ocperf, this tool can be found in the repository in here: https://github.com/andikleen/pmu-tools. Clone that repository in your home directory, then:

    $ make autofdo
    
Then before recompiling, you will need to change the RELEASEFLAGS variable to use the .afdo profile files

    $ make release
    
Execute the binaries again to measure the time and compare with other optimization methods.

## 3. Automation scripts

Under development




    
