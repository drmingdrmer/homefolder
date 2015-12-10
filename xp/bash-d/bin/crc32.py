#!/usr/bin/env python
# coding: utf-8

import sys
import binascii

if len( sys.argv ) > 1:
    fn = sys.argv[1]
    with open(fn) as f:
        cont = f.read()
else:
    cont = sys.stdin.read().strip()

crc32 = binascii.crc32( cont )
crc32 = crc32 % 0xffffffff
print crc32
print '%08x' % crc32
