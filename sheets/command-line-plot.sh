# eplot:
# Output file format options:
#  -P --png        Output to the PNG file foo.png
#  -p --postscript Output to the postscript file foo.ps
#  -a --pdf        Output to the pdf file foo.pdf
#  -e --emf        Output to the emf file foo.emf
#  -o <fname>      Specify the output filename
#  -d --dumb       Output to dumb terminal (ascii art)

# # two column:
# x1 y1
# x2 y2
# ...
cat a.txt | eplot -d

# # single column:
# y1
# y2
# ...
cat a.txt | eplot -d

#   7 +--------------------------------------------------------------------+
#     |         +         +         +        +         +         +         |
# 6.5 |******                                                      *******-|
#     |      ************                                                  |
#   6 |-+                ****                                            +-|
#     |                      **                                            |
# 5.5 |-+                     ********                                   +-|
#     |                               ***                                  |
#   5 |-+                               *                                +-|
#     |                                 ***                                |
# 4.5 |-+                                  ***                           +-|
#     |                                      ***                           |
#   4 |-+                                      **                        +-|
#     |                                         **                         |
# 3.5 |-+                                        **                      +-|
#     |                                           **                       |
#   3 |-+                                          *****                 +-|
#     |                                                *********           |
# 2.5 |-+                                                      ******    +-|
#     |         +         +         +        +         +         +  ****** |
#   2 +--------------------------------------------------------------------+
#     0         1         2         3        4         5         6         7


# use the first column as x-axis
seq 30 | awk '{print 2*$1, $1*$1}'  | feedgnuplot --terminal 'dumb 30,15' --exit --domain
# treat the first column as a y-value series
seq 30 | awk '{print 2*$1, $1*$1}'  | feedgnuplot --terminal 'dumb 30,15' --exit
# 16 +--------------------+
# 14 |-+..+.+.+..+.+.+..+-|
#    | A  : : :  : : :  : |
# 12 |-:AAA.:.:..:.:.:..:-|
# 10 |-:..AAA.:..:.:.:..:-|
#  8 |-:..:.AAA..:.:.:..:-|
#    | :  : : AA : : :  : |
#  6 |-:..:.:.:AAAA:.:..:-|
#  4 |-:..:.:.:..:AAAA..:-|
#    | :  : : :  : : AAA: |
#  2 |-+..+.+.+..+.+.+.A+-|
#  0 +--------------------+
#    0 1  2 3 4  5 6 7  8 9



# ascii flow chart
#
# brew install cpanminus
# cpan Graph::Easy
# http://cpansearch.perl.org/src/TELS/Graph-Easy-0.64/README

echo "[ Bonn ] - car -> [ Berlin ]" | /usr/local/Cellar/perl/5.24.1/bin/graph-easy   --as boxart
# ┌──────┐  car   ┌────────┐
# │ Bonn │ ─────> │ Berlin │
# └──────┘        └────────┘

# use .dot as input
cat test.dot | /usr/local/Cellar/perl/5.24.1/bin/graph-easy  --from graphviz
# graph {
#     a -> b;
#     b -> c;
#     a -> c;
#     d -> c;
#     e -> c;
#     e -> a;
# }

#    ┌───┐
#    │ d │
#    └───┘
#      │
#      │
#      ▼
#    ┌────────┐
# ┌▶ │   c    │
# │  └────────┘
# │    ▲    ▲
# │    │    │
# │    │    │
# │  ┌───┐  │
# │  │ e │  │
# │  └───┘  │
# │    │    │
# │    │    │
# │    ▼    │
# │  ┌───┐  │
# └─ │ a │  │
#    └───┘  │
#      │    │
#      │    │
#      ▼    │
#    ┌───┐  │
#    │ b │ ─┘
#    └───┘
