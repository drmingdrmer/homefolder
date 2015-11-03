#!/usr/bin/env python
# coding: utf-8

import sys
import binascii

if len( sys.argv ) > 1:
    fn = sys.argv[1]
    with open(fn) as f:
        cont = f.read()
else:
    cont = sys.stdin.read()

crc32 = binascii.crc32( cont )
print '%08x' % crc32
