#!/bin/sh

brew install imagemagick --with-ghostscript

convert -density 150 x.pdf -quality 90 ec-%02d.jpg
