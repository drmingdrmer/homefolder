#!/bin/sh

# mac:
# brew cask install wkhtmltopdf

wkhtmltoimage x.html x.jpg
wkhtmltopdf x.html x.pdf
