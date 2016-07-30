#! /bin/bash

libname=libchw.so
links="-lsfml-graphics -lsfml-window -lsfml-system"

compile_options="-std=c++11 -Wall -Werror $links"

# compile each file 
shopt -s nullglob
for f in src/c/*.cpp; do
    bname=$(basename $f)
    g++-5 -c -fPIC $compile_options $f -o obj/"${bname%.*}.o" | tee /dev/tty
done

# link to make a shared lib
obj_files=obj/*.o
g++-5 -shared -fPIC $obj_files -o lib/$libname | tee /dev/tty
