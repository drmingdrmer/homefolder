#!/usr/bin/env python2
# coding: utf-8

import random
import string
import sys

if len(sys.argv) == 1:
    n = 15
else:
    n = int(sys.argv[1])

chars = string.ascii_letters + string.digits

print ''.join([random.choice(chars) for x in range(n)])

