#!/bin/sh

# imagemagick

#                    <origin>             <compressed>  <output-diff-map>
compare -metric PSNR ps-cubic-sharper.jpg ps-60.jpg     diff-60.png
