#! /bin/bash

compiler="g++-5"
libname=libchw.so

# include directory for SFML headers
include="-I include"

compile_options="-O3 -g -std=c++11 -Wall -Werror $include"

# make folders if necessary
mkdir -p bin
mkdir -p lib
mkdir -p obj

# remove ctest object file if necessary ...
rm obj/ctest.o 2> /dev/null

# compile each file 
shopt -s nullglob
for f in src/c/*.cpp; do
    bname=$(basename $f)
    $compiler -c -fPIC $compile_options $f -o obj/"${bname%.*}.o" | tee /dev/tty
done

# link to make a shared lib
obj_files=obj/*.o
$compiler -shared -fPIC $obj_files -o lib/$libname | tee /dev/tty
