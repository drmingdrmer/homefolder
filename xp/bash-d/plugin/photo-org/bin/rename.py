#!/usr/bin/env python
# coding: utf-8

import os
import stat
import datetime

fns = os.listdir( "." )

for fn in fns:

    if not os.path.isfile( fn ):
        continue

    if fn.startswith('2014'):
        continue

    st = os.stat( fn )

    ctime = st[stat.ST_MTIME] + 8 * 3600
    dt = datetime.datetime.utcfromtimestamp( ctime )
    timestr = dt.strftime( "%Y-%m-%d %H.%M.%S" )

    target = timestr + '.jpg'
    print fn, target

    if os.path.exists( target ):
        target = timestr + "-" + fn[-4:] + ".jpg"

    if os.path.exists( target ):
        raise 1

    os.rename( fn, target )
