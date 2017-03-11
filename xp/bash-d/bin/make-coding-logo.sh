#!/bin/sh

name=$2

convert -define jpeg:size=200x200 "$1"  -thumbnail 400x400^ -gravity center -extent 400x400 tmp.gif

max_width=720
l=${#name}
if [ $l -le 6 ]; then
    fontsize=120
else
    let fontsize=720/l
fi

convert tmp.gif  -weight 700  -pointsize $fontsize  -fill black -draw "rectangle 0,250 400,400" -draw "gravity north fill white text 0,250 '$name' " "$1.logo.gif"

