#!/bin/sh

for f in $(find . -maxdepth 1 -type f)
do
    echo $f
    gifsicle -O2 --resize-width 200 --colors 64 $f -o tt/$f
done
