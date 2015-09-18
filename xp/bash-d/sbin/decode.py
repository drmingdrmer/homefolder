#!/usr/bin/env python2.6
# coding: utf-8

import os, sys
import urllib


def tt( oriname, act, enc = 'gbk' ):

    b = urllib.unquote_plus(oriname)

    try:
        c = b.decode( enc ).encode( 'utf-8' )
    except Exception, e:
        pass
    else:
        if act == 'convert':
            os.write( 1, c )
        elif act == 'rename':
            os.rename( oriname, c )
        else:
            os.write( 2, 'Invalid Action: ' + repr( act ) )
            sys.exit( 1 )

        sys.exit( 0 )


if __name__ == "__main__":

    if len( sys.argv ) > 2:
        act, oriname = sys.argv[ 1:3 ]
    else:
        act, oriname = 'convert', sys.argv[ 1 ]

    for enc in [ 'gbk', 'utf-8', 'gb18030' ]:
        tt( oriname, act, enc )
