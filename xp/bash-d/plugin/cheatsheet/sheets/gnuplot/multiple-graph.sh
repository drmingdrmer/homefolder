#!/bin/sh

# output multipel graph

gnuplot <<-END
set terminal dumb

set multiplot                       # multiplot mode (prompt changes to 'multiplot')
set size 1, 0.5

set origin 0.0,0.5
plot sin(x), log(x)

set origin 0.0,0.0
plot sin(x), log(x), cos(x)

unset multiplot                     # exit multiplot mode (prompt changes back to 'gnuplot')
END
