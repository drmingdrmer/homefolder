#!/bin/sh

{
cat <<-END
set terminal dumb

set style line 1 lc rgb 'black' pt 5   # square
set style line 2 lc rgb 'black' pt 7   # circle
set style line 3 lc rgb 'black' pt 9   # triangle

plot "fn" with points linestyle 1, \
     "fn" with points linestyle 2,
END
} | gnuplot
