#!/bin/sh

readlink -m /usr/local/bin/perl

# only gnu-readlink has `-m` option on mac
greadlink -m /usr/local/bin/perl
