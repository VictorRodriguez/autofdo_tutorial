SHELL = /bin/sh
CC    = gcc

FLAGS        = -std=gnu99 -Iinclude
CFLAGS       = -pedantic -Wall -Wextra -march=native -ggdb3
LIBS         = -lm
DEBUGFLAGS   = -O0 -D _DEBUG
RELEASEFLAGS = -O3 -D NDEBUG

SOURCES = $(shell echo src/*.c)
COMMON  = include/definitions.h include/debug.h
HEADERS = $(shell echo include/*.h)
OBJECTS = $(SOURCES:.c=.o)
COBJECTS= src/debug.o
CSOURCES= src/debug.c
BINARIES= bubble_sort matrix_multiplication pi_calculation

PREFIX = $(DESTDIR)/usr/local
BINDIR = $(PREFIX)/bin


all: $(BINARIES)

# $(TARGET): src/main.o $(OBJECTS) $(COMMON)
# 	$(CC) $(FLAGS) $(CFLAGS) $(LIBS) $(DEBUGFLAGS) -o $@ $(OBJECTS)

# release: $(SOURCES) $(HEADERS) $(COMMON)
# 	$(CC) $(FLAGS) $(CFLAGS) $(LIBS) $(RELEASEFLAGS) -o $(TARGET) $(SOURCES)

release: $(SOURCES) $(HEADERS) $(COMMON) $(CSOURCES)
	$(foreach BINARY,$(BINARIES),$(CC) $(FLAGS) $(CFLAGS) $(LIBS) $(RELEASEFLAGS) -o $(BINARY)_optimized src/$(BINARY).c $(CSOURCES);)

install: release
	install -D $(TARGET) $(BINDIR)/$(TARGET)

install-strip: release
	install -D -s $(TARGET) $(BINDIR)/$(TARGET)

uninstall:
	-rm $(BINDIR)/$(TARGET)

clean:
	-rm -f $(OBJECTS)
	-rm -f perf.data*
	-rm -f *.afdo*
	-rm -f *.gcda

distclean: clean
	-rm -f $(BINARIES)
	$(foreach BINARY,$(BINARIES), rm -f $(BINARY)_autofdo; rm -f $(BINARY)_optimized;)

default:
	gcc main.c bubble_sort.c pi_calculation.c matrix_multiplication.c -lm -o demo

remove:
	rm -rf demo*
	rm -rf *.data*
	rm -rf *.afdo*
	rm -rf *.gcda

optimized:
	$(CC) $(FLAGS) $(LIBS) -O3 $(SOURCES) -o demo_optimized

normalfdo:
	$(CC) -g3 $(FLAGS) $(LIBS) $(SOURCES) -o demo_instrumented -fprofile-generate
	./demo_instrumented
	$(CC) $(FLAGS) $(LIBS) -O3 $(SOURCES) -o demo_normalfdo -fprofile-use

# autofdo: $(BINARIES)
# 	~/pmu-tools/ocperf.py record -b -e br_inst_retired.near_taken -- ./demo
# 	/tmp/autofdo/create_gcov --binary=./demo --profile=perf.data --gcov=demo.afdo -gcov_version=1
# 	$(CC) $(FLAGS) $(LIBS) -O3 -fauto-profile=demo.afdo $(SOURCES) -o demo_autofdo

autofdo: $(BINARIES)
	$(foreach BINARY,$(BINARIES),~/pmu-tools/ocperf.py record -b -e br_inst_retired.near_taken -- ./$(BINARY);/tmp/autofdo/create_gcov --binary=./$(BINARY) --profile=perf.data --gcov=$(BINARY).afdo -gcov_version=1;$(CC) $(FLAGS) $(LIBS) -O3 -fauto-profile=$(BINARY).afdo src/$(BINARY).c $(CSOURCES) -o $(BINARY)_autofdo;)

bubble_sort: src/bubble_sort.o $(COBJECTS) $(HEADERS) $(COMMON)
	$(CC) $(FLAGS) $(CFLAGS) $(LIBS) $(DEBUGFLAGS) -o $@ $< $(COBJECTS)

matrix_multiplication: src/matrix_multiplication.o $(COBJECTS) $(HEADERS) $(COMMON)
	$(CC) $(FLAGS) $(CFLAGS) $(LIBS) $(DEBUGFLAGS) -o $@ $< $(COBJECTS)

pi_calculation: src/pi_calculation.o $(COBJECTS) $(HEADERS) $(COMMON)
	$(CC) $(FLAGS) $(CFLAGS) $(LIBS) $(DEBUGFLAGS) -o $@ $< $(COBJECTS)

%.o: %.c $(HEADERS) $(COMMON)
	$(CC) $(FLAGS) $(CFLAGS) $(DEBUGFLAGS) -c -o $@ $<



.PHONY : all release install install-strip uninstall clean distclean autofdo normalfdo
