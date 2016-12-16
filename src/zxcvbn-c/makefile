CFLAGS ?= -O2 -Wall -Wextra -Wdeclaration-after-statement
CXXFLAGS ?= -O2 -Wall -Wextra

# default programs
CC ?= gcc
AR ?= ar
CXX ?= g++

# need zxcvbn.h prior to package installation
CPPFLAGS += -I.

# library metadata
TARGET_LIB = libzxcvbn.so.0.0.0
SONAME = libzxcvbn.so.0

WORDS = words-eng_wiki.txt words-female.txt words-male.txt words-passwd.txt words-surname.txt words-tv_film.txt

#all: test-file test-inline test-c++inline test-c++file test-shlib test-statlib
all: test-statlib

test-shlib: test.c $(TARGET_LIB)
	if [ ! -e libzxcvbn.so ]; then ln -s $(TARGET_LIB) libzxcvbn.so; fi
	$(CC) $(CPPFLAGS) $(CFLAGS) -o $@ $< -L. $(LDFLAGS) libzxcvbn.so -lm

$(TARGET_LIB): zxcvbn-inline-pic.o
	$(CC) $(CPPFLAGS) $(CFLAGS) \
		-o $@ $^ -fPIC -shared -Wl,-soname,$(SONAME) $(LDFLAGS) -lm
	if [ ! -e $(SONAME) ]; then ln -s $(TARGET_LIB) $(SONAME); fi

test-statlib: test.c libzxcvbn.a
	$(CC) $(CPPFLAGS) $(CFLAGS) -o $@ $^ $(LDFLAGS) -lm

libzxcvbn.a: zxcvbn-inline.o
	$(AR) cvq $@ $^

test-file: test.c zxcvbn-file.o
	$(CC) $(CPPFLAGS) $(CFLAGS) \
		-DUSE_DICT_FILE -o test-file test.c zxcvbn-file.o $(LDFLAGS) -lm

zxcvbn-file.o: zxcvbn.c dict-crc.h zxcvbn.h
	$(CC) $(CPPFLAGS) $(CFLAGS) \
		-DUSE_DICT_FILE -c -o zxcvbn-file.o zxcvbn.c

test-inline: test.c zxcvbn-inline.o
	$(CC) $(CPPFLAGS) $(CFLAGS) \
		-o test-inline test.c zxcvbn-inline.o $(LDFLAGS) -lm

zxcvbn-inline-pic.o: zxcvbn.c dict-src.h zxcvbn.h
	$(CC) $(CPPFLAGS) $(CFLAGS) -fPIC -c -o $@ $<

zxcvbn-inline.o: zxcvbn.c dict-src.h zxcvbn.h
	$(CC) $(CPPFLAGS) $(CFLAGS) -c -o zxcvbn-inline.o zxcvbn.c

dict-src.h: dictgen $(WORDS)
	./dictgen -o dict-src.h $(WORDS)

dict-crc.h: dictgen $(WORDS)
	./dictgen -b -o zxcvbn.dict -h dict-crc.h $(WORDS)

dictgen: dict-generate.cpp makefile
	$(CXX) $(CPPFLAGS) -std=c++11 $(CXXFLAGS) \
		-o dictgen dict-generate.cpp $(LDFLAGS)

test-c++inline: test.c zxcvbn-c++inline.o
	if [ ! -e test.cpp ]; then ln -s test.c test.cpp; fi
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) \
		-o test-c++inline test.cpp zxcvbn-c++inline.o $(LDFLAGS) -lm

zxcvbn-c++inline.o: zxcvbn.c dict-src.h zxcvbn.h
	if [ ! -e zxcvbn.cpp ]; then ln -s zxcvbn.c zxcvbn.cpp; fi
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) \
		-c -o zxcvbn-c++inline.o zxcvbn.cpp

test-c++file: test.c zxcvbn-c++file.o
	if [ ! -e test.cpp ]; then ln -s test.c test.cpp; fi
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) \
		-DUSE_DICT_FILE -o test-c++file test.cpp zxcvbn-c++file.o $(LDFLAGS) -lm

zxcvbn-c++file.o: zxcvbn.c dict-crc.h zxcvbn.h 
	if [ ! -e zxcvbn.cpp ]; then ln -s zxcvbn.c zxcvbn.cpp; fi
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) \
		-DUSE_DICT_FILE -c -o zxcvbn-c++file.o zxcvbn.cpp

test: test-file test-inline test-c++inline test-c++file test-shlib test-statlib testcases.txt
	@echo Testing C build, dictionary from file
	./test-file -t testcases.txt
	@echo Testing C build, dictionary in executable
	./test-inline -t testcases.txt
	@echo Testing C shlib, dictionary in shlib
	LD_LIBRARY_PATH=. ./test-shlib -t testcases.txt
	@echo Testing C static lib, dictionary in lib
	./test-statlib -t testcases.txt
	@echo Testing C++ build, dictionary from file
	./test-c++file -t testcases.txt
	@echo Testing C++ build, dictionary in executable
	./test-c++inline -t testcases.txt
	@echo Finished

clean:
	rm -f test-file zxcvbn-file.o test-c++file zxcvbn-c++file.o 
	rm -f test-inline zxcvbn-inline.o zxcvbn-inline-pic.o test-c++inline zxcvbn-c++inline.o
	rm -f dict-*.h zxcvbn.dict zxcvbn.cpp test.cpp
	rm -f dictgen
	rm -f ${TARGET_LIB} ${SONAME} libzxcvbn.so test-shlib libzxcvbn.a test-statlib
