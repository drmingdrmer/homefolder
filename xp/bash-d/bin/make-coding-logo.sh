#!/bin/sh

# usage:
# > make-coding-log.sh x.png title
#
# dependency:
# > brew install imagemagick

name=$2

convert -define jpeg:size=200x200 "$1"  -thumbnail 400x400^ -gravity center -extent 400x400 tmp.gif

box_height=150
let box_top=400-box_height
max_width=720

l=${#name}
if [ $l -le 6 ]; then
    fontsize=120
else
    let fontsize=720/l
fi

let text_top=400-box_height/2-fontsize/2

convert tmp.gif \
    -weight 700 \
    -pointsize $fontsize  \
    -fill black \
    -draw "rectangle 0,$box_top 400,400" \
    -draw "gravity north fill white text 0,$text_top '$name'" \
    "$1.logo.gif"

