#!/usr/bin/env python2
# coding: utf-8

import os

def ren(path):

    fns = os.listdir(path)

    for fn in fns:

        try:
            t = fn.decode('utf-8')
            t = t.encode('gbk')
            t = t.decode('utf-8')
        except Exception as e:
            pass
        else:
            print 'rename gbk fn:', t
            p0 = os.path.join(path, fn)
            p1 = os.path.join(path, t)
            os.rename(p0, p1)

        try:
            unicodefn = fn.decode('utf-8')
            continue
        except UnicodeDecodeError as e:
            pass

        try:
            unicodefn = fn.decode('gbk')
        except UnicodeDecodeError as e:
            pass
        else:
            print 'rename gbk fn:', unicodefn
            p0 = os.path.join(path, fn)
            p1 = os.path.join(path, unicodefn.encode('utf-8'))
            os.rename(p0, p1)


    fns = os.listdir(path)
    for fn in fns:
        p = os.path.join(path, fn)

        if os.path.islink(p):
            continue

        if os.path.isdir(p):
            ren(p)

if __name__ == "__main__":
    ren('.')
