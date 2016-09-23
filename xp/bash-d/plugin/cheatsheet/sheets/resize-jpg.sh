#!/bin/sh

convert -resize "2048" "$i" "tt/$i"
convert -resize "50%" "$i" "tt/$i"
