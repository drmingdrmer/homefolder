#!/bin/sh

# http://gnuplot.sourceforge.net/demo/histograms.html


gnuplot <<-END

set terminal jpeg size 1800,1200;


set boxwidth 0.8
# set boxwidth 0.8 relative


# clustered style.
# gap default is 2 (bar-width)
set style histogram cluster gap 1


# border -1 gives bar border
set style fill solid border -1


# left and bottom border
set border 3 front ls 101


# add 0.3 space between x-axis and x-tics label 
set xtics offset 0,0.3,0


# customize x-labels
# set xtics ("April" 1, "May" 2, "June" 3, "July" 4)


# rotate x-label
set xtics border in scale 0,0 nomirror rotate by -45 autojustify


set style line 1 lc rgb '#aaffa5' pt 1 ps 1 lt 1 lw 2
set style line 2 lc rgb '#82da7d' pt 6 ps 1 lt 1 lw 2

plot "bench_get.data" using 2:xtic(1) with histogram linestyle 1 title "u16", \
     ''               using 3:xtic(1) with histogram linestyle 2 title "u32"



# customize x-labels
# https://stackoverflow.com/questions/15975631/gnuplot-xticlabels-with-several-lines

plot for [col=2:max_col] fn                        \
using col:xticlabels(gprintf('10^{%T}',column(1))) \
with histogram                                     \
linestyle col-1                                    \
title columnheader
END
