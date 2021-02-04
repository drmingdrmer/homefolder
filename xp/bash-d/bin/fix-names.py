#!/usr/bin/env python
# coding: utf-8

import os
import sys
import re

"""
recursively find invalid char in filenames and rename it.
"""

def getinput( prompt, acceptinput = lambda x : True ):

    try:
        '1' in acceptinput
        acpt_func = lambda x : x in acceptinput
    except:
        acpt_func = acceptinput


    while True:

        try :
            r = input( prompt ).strip()
            if acpt_func( r ):
                break

        except KeyboardInterrupt:
            r = None
            print()


    return r

def get_new_name(name):
    rr = repr(name)
    #  print(rr)
    newrr = rr
    newrr = re.sub(r'\\x\w\w', '', newrr)
    newrr = re.sub(r'(\\r|\\n)', '', newrr)

    newrr = re.sub(r'[/:<]', '-', newrr)

    #  leading space
    newrr = re.sub(r"^'  *", "'", newrr)

    #  some invalid uicode
    newrr = re.sub(r'\\u\w\w\w\w', '-', newrr)

    return newrr

def walk_dir(dir):

    for root, dirs, files in os.walk(dir):

        for name in files:
            rr = repr(name)
            newrr = get_new_name(name)
            if newrr != rr:
                newname = newrr[1:-1]
                print(root, ":")
                print("    ", repr(name))
                print("    ", repr(newname))

                p = os.path.join(root, name)
                newp = os.path.join(root, newname)

                if 'y' in getinput("rename[yn]? ", 'yn'):
                    os.rename(p, newp)

        #  dir rename not yet supported
        for name in dirs:
            rr = repr(name)
            newrr = get_new_name(name)
            if newrr != rr:
                newname = newrr[1:-1]
                print(root, ":")
                print("    ", repr(name))
                print("    ", repr(newname))

walk_dir(".")

#  a = '20180105-白山云CDN技术服务合同模版-清洁版 amendment 对照版-trans'
#  print(repr(a))
#  #  print(repr(re.sub(r'.', '', a, re.UNICODE)))
#  print(repr(re.sub(r'[\x00-\x20]', '-', a)))
