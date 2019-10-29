#!/bin/sh


gnuplot <<-'END'
set terminal pngcairo size 600,400

plot "edge-backsource-cost.txt" using 1:3 with lines linestyle 1 title  "storage cost", \
     STATS_min_y with lines linecolor rgb"#00ffff" notitle

END
