#! /bin/bash

# assuming build.sh has been run ...

compiler="g++-5"
exname=ctest
links="-lsfml-graphics -lsfml-window -lsfml-system"

compile_options="-O3 -std=c++11 -Wall -Werror $links"

shopt -s nullglob

$compiler -c $compile_options src/ctest/ctest.cpp -o obj/ctest.o | tee /dev/tty

obj_files=obj/*.o
$compiler $obj_files $compile_options -o bin/ctest | tee /dev/tty
