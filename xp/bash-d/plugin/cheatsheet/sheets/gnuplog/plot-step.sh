#!/bin/sh

gnuplot <<-'END'
set terminal dumb
x=0.; y=0.
a=0.; b=0.
plot '-' u (x=x+$1):(y=y+$2) w steps ls 1
1   2
1   1
1   -1
1   -1
e
END
