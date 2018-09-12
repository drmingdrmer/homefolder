#!/bin/sh

# fn:
# 19:20:21 1
# 19:20:23 2
{
cat <<-END
set terminal jpeg size 1800,1200;
set timefmt '%H:%M:%S'
set xdata time

plot "fn" using 1:2 with lines linestyle 1;
END
} | gnuplot
