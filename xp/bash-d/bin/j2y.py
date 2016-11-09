#!/usr/bin/env python
# coding: utf-8

# convert json to yaml

import sys

import json
import yaml

if len( sys.argv ) > 1:
    fn = sys.argv[1]
    with open(fn) as f:
        cont = f.read()
else:
    cont = sys.stdin.read()

datas = json.loads(cont, encoding='utf-8')

print yaml.safe_dump(datas,
                     encoding='utf-8',
                     allow_unicode=True,
                     default_flow_style=False
)
