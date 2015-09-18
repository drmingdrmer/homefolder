#!/usr/bin/env python
# coding: utf-8

import os
import stat
import datetime

fns = os.listdir( "." )

prev = 0
event = None

for fn in fns:

    if not os.path.isfile( fn ):
        continue

    if fn.startswith('.'):
        continue

    st = os.stat( fn )

    ctime = st[stat.ST_MTIME] + 8 * 3600

    if abs(ctime - prev) > 15*60:
        event = fn.rsplit('.', 1)[-2]
        print 'new', event

        efolder = os.path.join( 'events', event )
        os.mkdir( efolder, 0755 )

    target = os.path.join( 'events', event, fn )
    os.link( fn, target )

    prev = ctime
