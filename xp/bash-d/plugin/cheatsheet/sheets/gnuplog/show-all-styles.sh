#!/bin/sh

gnuplot <<-END
set terminal dumb size 120,50
test
END

# +-dumb  terminal test--------------------------------------show ticscale--------------------------------------1-+---+--+
# |                                                           $$$                                               0 +...+ .|
# | gnuplot version 5.2.2                                     :               filled polygons:                  1 ***** A|
# |                                                           :                    XXXXXXX                      2 ##### B|
# |                                                           :                   XXXXXXXX                      3 $$$$$ C|
# |                                                           :                   XXXXXXXXX                     4 %%%%% D|
# |                                                           :                  XXXXXXXXXXXXXXX                5 @@@@@ E|
# |                                                           :                  XXXXXXXXXXXXXXX                6 &&&&& F|
# |                                                           :                 XXXXXXXXXXXXXXXXX               7 ===== G|
# |                                                           :                  XXXXXXXXXXXXXXXX               8 ***** H|
# |                                                           :                  XXXXXXXXXXXXXXXXX              9 ***** I|
# |                                                           :                   XXXXXXXXXXXXXXXXX            10 ##### J|
# |                                                           :                   XXXXXXXXXXXXXXXX             11 $$$$$ K|
# |                                                           :                    XXXXXXXXXXXXXXX             12 %%%%% L|
# |                                                           :                         XXXXXXXXX              13 @@@@@ M|
# |                                                           :                         XXXXXXXXX              14 &&&&& N|
# |                                                           :                          XXXXXXX               15 ===== O|
# | ^            .>                                           :                                                16 ***** P|
# | |          ..                                             left justified                                   17 ***** Q|
# | |        ..                                         centre+d text                                          18 ##### R|
# | |      ..                                  right justified:                                                19 $$$$$ S|
# | |    ..                                                   :                                                20 %%%%% T|
# | |  ..                                                     :                                                21 @@@@@ U|
# | |..                                      true vs. estimated text dimensions                                22 &&&&& V|
# +.cannot rotate text..............................+-------------------+......................................23.=====.W+
# | |  ..                                                     :                                                24 ***** X|
# | |    ..                                                   :                                                25 ***** Y|
# | |      ..                                                 :                                                26 ##### Z|
# | |        ..                                               :                 n+1                            27 $$$$$ A|
# | |          ..                                             Enhanced text:   x0                              28 %%%%% B|
# | |            .                                            :                                                29 @@@@@ C|
# | |             >                                           :                                                30 &&&&& D|
# |                                                           :               Bold Italic                      31 ===== E|
# |                                                           :                                                32 ***** F|
# |                                                           :                                                33 ***** G|
# |        linewidth                                          :                                                34 ##### H|
# |                                                           :                                                35 $$$$$ I|
# |        +-----------  lw 6         dashtype                :                                                36 %%%%% J|
# |                                                           :                                                37 @@@@@ K|
# |        +-----------  lw 5         +-----------  dt 5      :                                                38 &&&&& L|
# |                                                           :                                                39 ===== M|
# |        +-----------  lw 4         +-----------  dt 4      :                                                40 ***** N|
# |                                                           :                    pattern fill                41 ***** O|
# |        +-----------  lw 3         +-----------  dt 3      + 0++ 1++ 2++ 3++ 4++ 5++ 6++ 7++ 8+             42 ##### P|
# |                                                           |  ||  ||  ||  ||  ||  ||  ||  ||  |             43 $$$$$ Q|
# |        +-----------  lw 2         +-----------  dt 2      |  ||  ||  ||  ||  ||  ||  ||  ||  |             44 %%%%% R|
# |                                                           |  ||  ||  ||  ||  ||  ||  ||  ||  |             45 @@@@@ S|
# |        +-----------  lw 1         +-----------  dt 1      |  ||  ||  ||  ||  ||  ||  ||  ||  |             46 &&&&& T|
# |                                                           |  ||  ||  ||  ||  ||  ||  ||  ||  |                       |
# +-----------------------------------------------------------+--++--++--++--++--++--++--++--++--+-----------------------+