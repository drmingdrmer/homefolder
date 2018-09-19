#!/bin/sh


mkdir font-img
ls fonts/ | while read fn; do
# echo "($fn)"
convert -pointsize 120 -font "fonts/$fn" \
    "label:中文中文 $fn"   "font-img/$fn.gif"
done
