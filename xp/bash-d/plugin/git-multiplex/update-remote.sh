#!/bin/sh

(
cd src \
    && make
) || exit 1

(
cd repo \
    && ./ctl commit \
    && ./ctl push
) || exit 1
 
(
cd gist \
    && ./gist-ctrl commit \
    && ./gist-ctrl push
) || exit 1

