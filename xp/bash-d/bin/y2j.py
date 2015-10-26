#!/usr/bin/env python
# coding: utf-8

# convert yaml to json

import sys

import json
import yaml

if len( sys.argv ) > 1:
    fn = sys.argv[1]
    with open(fn) as f:
        cont = f.read()
else:
    cont = sys.stdin.read()

datas = yaml.load(cont)

print json.dumps(datas,
                 indent=2,
                 encoding='utf-8',
)
