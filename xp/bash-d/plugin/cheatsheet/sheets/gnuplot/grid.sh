#!/bin/sh
gnuplot <<-END
set terminal jpeg size 800,600;

set yr [5:20]

# show y grid
set grid ytics

plot "bench_get.data" using 2:xtic(1) with histogram linestyle 1 title "u16"
END
