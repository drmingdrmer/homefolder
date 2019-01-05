#!/bin/sh

fn="${1}"
pdf="${fn%.*}.pdf"
png="${fn%.*}.png"
cropped="/tmp/x.pdf"

# latex to pdf
pdflatex "$fn"

# crop pdf to minimal size
pdfcrop "$pdf" "$cropped"

# convert pdf to png, no bg
convert -density 200 "$cropped" -quality 50 "$png"

# another way to convert, white bg
# pdftoppm "$cropped" | pnmtopng > "$png"


rm "$cropped" "$pdf" \
    "${pdf%.*}.log" \
    "${pdf%.*}.aux"
