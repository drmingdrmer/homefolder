#!/usr/bin/env python2
# coding: utf-8

import json
import sys
import pprint


if len( sys.argv ) > 1:

    fn = sys.argv[ 1 ]
    with open( fn, 'r' ) as f:
        cont = f.read()
else:
    cont = sys.stdin.read()

try:
    pprint.pprint( json.loads( cont, encoding='utf-8' ) )
except ValueError, e:
    print cont
