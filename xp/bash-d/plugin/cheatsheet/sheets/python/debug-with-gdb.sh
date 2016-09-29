#!/bin/sh

debuginfo-install python-2.7.5-39.el7_2.x86_64

gdb python 5940

# display backtrace for python
py-bt

# https://fedoraproject.org/wiki/Features/EasierPythonDebugging
