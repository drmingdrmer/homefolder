#!/bin/sh
gnuplot <<-END
set termoption enhanced

# a superscript pow
set format x '%.1t 10^{%T}'
plot "vec.dat" using 1:2 title 'line 1' with linespoints

END

# Format        Explanation
# %f            floating point notation
# %e or %E      exponential notation; an "e" or "E" before the power
# %g or %G      the shorter of %e (or %E) and %f
# %x or %X      hex
# %o or %O      octal
# %t            mantissa to base 10
# %l            mantissa to base of current logscale
# %s            mantissa to base of current logscale; scientific power
# %T            power to base 10
# %L            power to base of current logscale
# %S            scientific power
# %c            character replacement for scientific power
# %P            multiple of pi

