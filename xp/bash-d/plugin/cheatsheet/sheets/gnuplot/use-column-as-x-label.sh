#!/bin/sh


# 1 foo.jsp    1234
# 2 bar.jsp    6653
# 3 foobar.jsp 9986
# 2 bar.jsp    2221
# 1 foo.jsp    5643

gnuplot <<-END
set terminal jpeg size 1800,1200;

# using column 2 as title
plot "example" using 1:3:xtic(2) with points
END
