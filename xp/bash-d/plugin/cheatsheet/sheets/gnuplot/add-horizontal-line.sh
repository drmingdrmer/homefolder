#!/bin/sh

gnuplot <<-END

# Add line at -3db
# Draw a line from the right end of the graph to the left end of the graph at
# the y value of -3
# The line should not have an arrowhead
# Linewidth = 2
# Linecolor = black
# It should be in front of anything else drawn
set arrow from graph 0,first -3 to graph 1, first -3 nohead lw 2 lc rgb "#000000" front

# Put a label -3db at 80% the width of the graph and y = -2 (it will be just above the line drawn)
set label "-3dB" at graph 0.8, first -2

END
