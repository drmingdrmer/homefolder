#!/bin/sh
gnuplot <<-END
set termoption enhanced

set ylabel "Y Label" offset 3,0,0
# which moves the ylabel 3 characters toward the x axis (and 0 towards the y and
# z axes) relative to its original position.

END
