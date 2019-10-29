#!/bin/sh
gnuplot <<-END
set terminal jpeg size 800,600;

END

 # set style line <index> {{linetype  | lt} <line_type> | <colorspec>}
 #                        {{linecolor | lc} <colorspec>}
 #                        {{linewidth | lw} <line_width>}
 #                        {{pointtype | pt} <point_type>}
 #                        {{pointsize | ps} <point_size>}
 #                        {palette}
