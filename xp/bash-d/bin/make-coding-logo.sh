#!/bin/sh

name=$2

convert -define jpeg:size=200x200 "$1"  -thumbnail 400x400^ -gravity center -extent 400x400 tmp.gif

convert tmp.gif  -weight 700  -pointsize 80  -fill black -draw "rectangle 0,320 400,400" -draw "gravity north fill white text 0,320 '$name' " "$1.logo.gif"

