#!/usr/bin/env python2
# coding: utf-8


import os
import sys
from PIL import Image

def outfn( fn ):
    tfn = fn.rsplit( ".", 1 )
    tfn = "output/" + tfn[ 0 ] + "." + tfn[ 1 ]
    return tfn

def parse_size( size_str ):
    w, h = size_str.split( '*', 1 )
    return int( w ), int( h )

def target_size( img, size, inside ):
    w, h = img.size

    ratio_w = float( size[ 0 ] ) / w
    ratio_h = float( size[ 1 ] ) / h

    if inside:
        ratio = min( [ ratio_w, ratio_h ] )
    else:
        ratio = max( [ ratio_w, ratio_h ] )

    w, h = int( w*ratio ), int( h*ratio )
    return w, h

def maxwidth( sess, n ):
    return inbox( sess, n + '*100000000' )

def maxheight( sess, n ):
    return inbox( sess, '100000000*' + n )

def fillbox( sess, size_str ):

    img = sess[ 'img' ]
    size = parse_size( size_str )
    w, h = target_size( img, size, False )

    img = img.resize( ( w, h ), Image.BILINEAR )

    box = None
    if w > size[ 0 ]:
        diff = (w - size[ 0 ]) /2
        box = ( diff, 0, w-diff, h )
    elif h > size[1]:
        diff = ( h-size[1] )/2
        box = ( 0, diff, w, h-diff )

    if box is not None:
        img = img.crop( box )

    return img

def inbox( sess, size_str ):
    img = sess[ 'img' ]
    size = parse_size( size_str )
    w, h = target_size( img, size, True )

    return img.resize( ( w, h ), Image.BILINEAR )

def write( sess, fn ):
    if fn == '':
        fn = outfn( sess[ 'fn' ] )
    sess[ 'img' ].save( fn )

commands = dict(
        inbox=inbox,
        write=write,
        fillbox=fillbox,
        maxwidth=maxwidth,
        maxheight=maxheight,
)
def chain():
    # fillbox:n*n inbox:n*n write:fn
    cmds = sys.argv
    fn = cmds[ 1 ]
    cmds = cmds[ 2: ]

    sess = {
            'img': Image.open( fn ),
            'fn': fn,
    }
    for cmd_arg in cmds:
        cmd, arg = cmd_arg.split( ":", 1 )
        sess[ 'img' ] = commands[ cmd ]( sess, arg )

if __name__ == "__main__":
    chain()
