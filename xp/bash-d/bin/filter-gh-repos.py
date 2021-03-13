#!/usr/bin/env python
# coding: utf-8


import sys, json
j=json.loads(sys.stdin.read())

print("| name | tags | desc |")
print("| :-- | :-- | :-- |")
for l in j:
    l["tags"] = " ".join(l["tags"]).lower()
    l["lang"] = l["lang"].lower()
    l = "| {name} | {lang} {tags} | {desc} |".format(**l)

    print(l)

