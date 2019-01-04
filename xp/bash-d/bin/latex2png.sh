#!/bin/sh

fn="${1}"
pdf="${fn%.*}.pdf"
png="${fn%.*}.png"
cropped="/tmp/x.pdf"

pdflatex "$fn"
pdfcrop "$pdf" "$cropped"

convert -density 200 "$cropped" -quality 50 "$png"

# pdftoppm "$cropped" | pnmtopng > "$png"
