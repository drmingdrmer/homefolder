#!/bin/sh

convert origin.jpg \
    -filter box -define filter:blur=0.707 \
    +distort SRT "0,0 0.8,1.0 0 0.3999,0.0" -crop 800x1000+0+0 \
    +distort SRT "0,0 1.0,0.8 0 0.0,0.3999" -crop 800x800+0+0 \
    -transpose \
    -filter cubic -define filter:b=0 -define filter:c=2.2 -define filter:blur=1.05 \
    -resize 380x380 \
    -transpose \
    im-cubic-sharp.jpg
