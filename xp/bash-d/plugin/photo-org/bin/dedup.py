#!/usr/bin/env python
# coding: utf-8

import os
import hashlib
import json
import re
import pprint

pp = pprint.pprint

sha1dir = '.bysha1'

infopath = '.info.json'
ignore = (
        r'^\..*',
)

dup_rename_regexps = (
        r'^ *\(\d+\)$',
        r'^ *\[\d+\]$',
        r'^ *-\d+$',
)

del_prefer = (
        r'/photo-from-iphone1/Masters/',
)

# collected from user decision
dirs_to_delete = []

def clean_all():

    index = index_all()
    save_info(index)

    kvs = index['sha1'].items()
    kvs.sort()

    for sha1, pathdic in kvs:

        if len(pathdic) == 1:
            continue

        # dd('dup:', sha1)

        ps = pathdic.keys()
        ps.sort()

        p0 = ps[0]
        for p in ps[1:]:

            longest, diff_p0, diff_p, change_a, change_b = diff(p0, p)

            dir_p0 = os.path.dirname(p0)
            dir_p  = os.path.dirname(p)

            fn_p0 = os.path.basename(p0)
            fn_p  = os.path.basename(p)

            # only renaming number is different:
            # ./果果 (4)/2014-11-26 20.03.13.mov
            # ./果果 (5)/2014-11-26 20.03.13.mov
            if diff_p0.isdigit() and diff_p.isdigit() and change_a == change_b:
                if diff_p0 > diff_p:
                    p0, p = p, p0

                p0 = del_file(p, p0)
                continue

            # in a same dir, different name
            if dir_p0 == dir_p:
                deleted = False
                for reg in dup_rename_regexps:
                    if diff_p0 == '' and re.match(reg, diff_p):
                        p0 = del_file(p, p0)
                        deleted = True
                    if diff_p == '' and re.match(reg, diff_p0):
                        p0 = del_file(p0, p)
                        deleted = True

                if deleted:
                    continue

            # same file in different dir
            if fn_p0 == fn_p:

                if dir_p0 in dirs_to_delete:
                    p0 = del_file(p0, p)
                    continue

                if dir_p in dirs_to_delete:
                    p0 = del_file(p, p0)
                    continue

                dd("dir prefered to remove:")
                for d in sorted(dirs_to_delete):
                    dd(color(d + '/', 'blue'))

                dd('')
                dd('1- ' + format_change(p0, change_a))
                dd('2- ' + format_change(p, change_b))

                ui = getinput('which to remove: [12]', '12')
                if ui == '1':
                    dirs_to_delete.append(dir_p0)
                    p0, p = p, p0
                else:
                    dirs_to_delete.append(dir_p)

                p0 = del_file(p, p0)
                continue

            # choose one by one
            dd('')
            dd('1- ' + format_change(p0, change_a))
            dd('2- ' + format_change(p, change_b))

            ui = getinput('which to remove: [12]', '12')
            if ui == '1':
                p0, p = p, p0

            p0 = del_file(p, p0)
            continue

def format_change(a, change_a, clr='blue'):
    rst = ''
    for i, c in enumerate(a):
        if i in change_a:
            rst += color(c, clr)
        else:
            rst += c
    return rst

def del_file(to_del, to_keep):
    assert os.path.exists(to_keep)
    assert os.path.exists(to_del)

    longest, _, _, change_a, change_b = diff(to_del, to_keep)

    dd(color('+: ', 'green') + format_change(to_keep, change_b, 'green'))
    dd(color('-: ', 'red') + format_change(to_del, change_a, 'red'))
    dd("")
    os.unlink(to_del)
    return to_keep

def color(s, clr):
    c = {
            'red' : '196',
            'green' : '46',
            'blue' : '67',
            'yellow' : '226',
    }
    return '\033[38;5;' + c.get(clr) + 'm' + s + '\033[0m'

def index_all():
    curinfo = try_load_index() or {'file':{}, 'sha1':{}}

    dd("indexing...")
    for dirpath, dirnames, filenames in os.walk("."):
        for fn in filenames:

            if is_ignored(dirpath, fn):
                continue

            path = os.path.join(dirpath, fn)
            path = path.decode('utf-8')

            if path in curinfo['file']:
                continue

            sha1 = get_sha1(path)

            curinfo['file'][path] = sha1
            dd("found:", sha1, path)

    # cleanup
    for path in curinfo['file'].keys():
        if not os.path.exists(path):
            dd("remove not-found:", path)
            del curinfo['file'][path]

    curinfo['sha1'] = {}
    for path, sha1 in curinfo['file'].items():
        if sha1 not in curinfo['sha1']:
            curinfo['sha1'][sha1] = {}

        curinfo['sha1'][sha1][path] = 1

    return curinfo

def readf(p):
    with open(p, 'r') as f:
        cont = f.read()
    return cont

def try_load_index():
    try:
        c = readf(infopath)
        return json.loads(c, 'utf-8')
    except IOError as e:
        pass

    return None

def save_info(info):
    with open(infopath, 'w') as f:
        f.write(json.dumps(info, 'utf-8'))

def is_ignored(dirpath, fn):
    for ign in ignore:
        if re.match(ign, fn):
            return True
    return False

def diff(a, b):
    diffmap = {
    }

    for ia in range(len(a)+1):

        for ib in range(len(b)+1):

            k = (ia, ib)
            if ia == 0:
                # largest subarray, unmatched chars, change list for a and b
                diffmap[k] = (0, '', b[:ib], (), ())
            elif ib == 0:
                diffmap[k] = (0, a[:ia], '', (), ())
            else:

                ca = a[ia-1]
                cb = b[ib-1]
                prev = diffmap[(ia-1, ib-1)]
                pa = diffmap[(ia-1, ib)]
                pb = diffmap[(ia, ib-1)]

                if ca == cb:
                    if pa[0] == prev[0] + 1 and pb[0] < prev[0] + 1:
                        diffmap[k] = (pa[0], pa[1] + ca, pa[2],
                                      pa[3] + (ia-1,), pa[4])

                    elif pb[0] == prev[0] + 1 and pa[0] < prev[0] + 1:
                        diffmap[k] = (pb[0], pb[1], pb[2] + cb,
                                      pb[3], pb[4] + (ib-1,), )

                    else:
                        diffmap[k] = (prev[0]+1, prev[1], prev[2],
                                      prev[3], prev[4] )

                else:

                    if pa[0] > pb[0]:
                        diffmap[k] = (pa[0], pa[1] + ca, pa[2],
                                      pa[3] + (ia-1,), pa[4])

                    elif pa[0] < pb[0]:
                        diffmap[k] = (pb[0], pb[1], pb[2] + cb,
                                      pb[3], pb[4] + (ib-1,), )

                    else:
                        # prefer equal length matching
                        if ia - 1 >= ib:
                            diffmap[k] = (pa[0], pa[1] + ca, pa[2],
                                          pa[3] + (ia-1,), pa[4])
                        else:
                            diffmap[k] = (pb[0], pb[1], pb[2] + cb,
                                          pb[3], pb[4] + (ib-1,), )

            # print repr(a[:ia])
            # print repr(b[:ib])
            # print diffmap[k]


    return diffmap[(len(a)-1, len(b)-1)]

def get_sha1( path ):

    s = hashlib.sha1()
    with open( path, 'r' ) as f:
        while True:
            buf = f.read( 1024*1024*32 )
            if buf == "":
                break

            s.update( buf )

    return s.hexdigest().lower()

def getinput( prompt, acceptinput = lambda x : True ):

    try:
        xx = '1' in acceptinput
        acpt_func = lambda x : x in acceptinput
    except:
        acpt_func = acceptinput


    while True:

        try :
            r = raw_input( prompt ).strip()
            if acpt_func( r ):
                break

        except KeyboardInterrupt:
            r = None
            print

    return r

def dd(*args):
    args = [ enc(x) for x in args ]
    os.write(1, ' '.join(args) + "\n")

def enc(x):
    if type(x) == type(u''):
        x = x.encode('utf-8')
    return str(x)

if __name__ == "__main__":
    # x = "21 (1)/"
    # y = "21/"
    # a, b, c = diff(x, y)
    # print a
    # print b
    # print c

    clean_all()
    # update_sha1()
