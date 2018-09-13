#!/bin/sh

gnuplot <<-END
set title 'Hello, world'                       # plot title
set xlabel 'Time'                              # x-axis label
set ylabel 'Distance'                          # y-axis label
END
