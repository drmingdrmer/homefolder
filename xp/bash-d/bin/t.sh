#!/bin/sh

if [ $# -eq 0 ]; then
    python2 -m unittest discover -v --failfast
else
    # find test from a subdir or a module
    python2 -m unittest discover -v --failfast -s "$1"
fi
