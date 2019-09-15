#!/bin/sh
gnuplot <<-END
set terminal jpeg size 800,600;


# plot title at the right top
set key font ",8"


# x-axis, the numbers
set xtics font "Verdana,8" 


plot "bench_get.data" using 2:xtic(1) with histogram linestyle 1 title "u16"
END
