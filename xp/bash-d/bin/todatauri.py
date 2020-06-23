#!/usr/bin/env python
# coding: utf-8

import os
import sys
import base64

if __name__ == "__main__":
    for fn in sys.argv[1:]:

        with open(fn, 'rb') as f:
            cont = f.read()

        #  datauri = b"data:{};base64,{}".format(b'image/png',
        #                                       base64.b64encode(cont))
        datauri = b"data:" + b'image/png;base64,' +  base64.b64encode(cont)
        img = '<img width="100%" src="{datauri}"/>'.format(
            datauri=datauri,
        )

        os.write(1, datauri)
        #  print(datauri[:100])
