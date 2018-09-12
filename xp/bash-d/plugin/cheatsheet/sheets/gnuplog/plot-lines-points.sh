#!/bin/sh

{
cat <<-END
set terminal dumb

set style line 1 lc rgb 'black' pt 5   # square
set pointtype 2

plot "fn" with lines linestyle 1 title "blabla", \
     "fn" with points pointtype 2
END
} | gnuplot
