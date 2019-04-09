#!/bin/sh

# http://gnuplot.sourceforge.net/demo/histograms.html


gnuplot <<-END

set terminal jpeg size 1800,1200;

set boxwidth 0.8
set style fill solid

set style line 1 lc rgb '#aaffa5' pt 1 ps 1 lt 1 lw 2
set style line 2 lc rgb '#82da7d' pt 6 ps 1 lt 1 lw 2

plot "bench_get.data" using 2:xtic(1) with histogram linestyle 1 title "u16", \
     ''               using 3:xtic(1) with histogram linestyle 2 title "u32"
END
