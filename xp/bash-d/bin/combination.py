#!/usr/bin/env python
# coding: utf-8

import sys


def combination(n, m):
    r = 1
    for i in range(m):
        r *= n-i

    for i in range(m):
        r /= i + 1

    return r

if __name__ == "__main__":

    args = sys.argv[1:]
    n = int(args.pop(0))
    m = int(args.pop(0))

    if len(args) > 0:
        p = args.pop(0)

        if p == 'day':
            p = 0.04 / 365

        else:
            p = float(p)

        print combination(n, m) * (p ** m) * ((1 - p) ** (n-m))
    else:
        print combination(n, m)
