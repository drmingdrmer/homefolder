#!/bin/sh

fn="${1}"
pdf="${fn%.*}.pdf"
png="${fn%.*}.png"
cropped="/tmp/x.pdf"

pdflatex "$fn"
pdfcrop "$pdf" "$cropped"
pdftoppm "$cropped" | pnmtopng > "$png"
