#!/bin/sh

(
cd src \
    && make
) || exit 1

(
cd repo \
    && ./ctl commit \
    && ./ctl fetch \
    && ./ctl rebase origin/master \
    && ./ctl push
) || exit 1
 
(
cd gist \
    && ./gist-ctrl commit \
    && ./gist-ctrl fetch \
    && ./gist-ctrl rebase origin/master \
    && ./gist-ctrl push
) || exit 1
