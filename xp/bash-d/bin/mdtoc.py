#!/usr/bin/env python
# coding: utf-8

import re
import os
import sys
import json
import argparse

config = {
        'gitbook' : {
                'regex': [
                        (r'[,?_*()&]', ''),
                        (r'[^0-9a-zA-Z_\u00ff-\uffff]', '-'),
                ]
        },
        'jekyll' : {
                'regex': [
                        (r'[,?_*()&:=+\[\].\^]', ''),
                        # unicode: 🌰 \U0001f330: in python is 2 unicode: u'\ud83c', u'\udf30'
                        (r'\ud83c.', ''),
                        (r'[^0-9a-zA-Z_\u00ff-\uffff]', '-'),
                ]
        }
}

toc_start = u'<!-- mdtoc start -->'
toc_end   = u'<!-- mdtoc end   -->'

def add_md_toc(path, engine):

    with open(path, 'r') as f:
        cont = f.read()

    _lines = cont.split('\n')

    lines = []

    # remove old mdtoc
    found = False
    toc_ln = 0
    skip = 0
    for i, l in enumerate(_lines):

        if skip > 0:
            skip -= 1
            continue

        if l == toc_start:
            toc_ln = i
            found = True
            continue
        elif l == toc_end:
            found = False
            continue

        if not found:
            if l.startswith('<a class="md-anchor"'):
                # skip previous blank line
                lines.pop(-1)
                # skip next
                skip = 1
            else:
                lines.append(l)

    headers, lines = find_headers(lines)

    # reduce level
    if len(headers) == 0 or headers[0][0] == 1:
        pass
    else:
        reduce_level = headers[0][0] - 1
        headers = [(max(1, x[0] - reduce_level),
                    x[1],
                    x[2])
                   for x in headers]

    # output
    toc = []
    for level, text, header_id in headers:
        text = text.replace('[', '\\[')
        text = text.replace(']', '\\]')
        s = ' ' * 4 * (level-1) + u'- [{text}]({{{{page.url}}}}#{header_id})'.format(text=text, header_id=header_id)
        toc.append(s)

    return ( u'\n'.join(lines[:toc_ln]) + u'\n'
             + toc_start + u'\n'
             + u'\n'
             + u'\n'.join(toc) + u'\n'
             + u'\n\n'
             + toc_end + u'\n'
             + u'\n'.join(lines[toc_ln:])
    )

def find_headers(lines):
    headers = []
    rst_lines = []
    isblock = False
    for line in lines:

        rst_lines.append(line)

        if line.strip().startswith('```'):
            isblock = not isblock

        if isblock:
            continue

        if not line.startswith('#'):
            continue

        level = 0
        while len(line) > 0 and line.startswith('#'):
            level += 1
            line = line[1:]

        text = line.strip()

        header_id = text

        for reg, repl in config[engine]['regex']:
            header_id = re.sub(reg, repl, header_id)

        header_id = header_id.lower()

        rst_lines = rst_lines[:-1] + ['', '<a class="md-anchor" name="'+header_id+'"></a>', ''] + [rst_lines[-1]]

        headers.append((level, text, header_id))

    return headers, rst_lines



if __name__ == "__main__":

    parser = argparse.ArgumentParser(description='markdown TOC maker')

    parser.add_argument('fns', type=str, nargs='+', help='file names')
    parser.add_argument('-i', action="store_true", dest="inplace", help="in-place")
    parser.add_argument('-e', '--engine' action="store", dest="markdown engine", default="jekyll", help="markdown engine: jekyll, gitbook")

    args = parser.parse_args()

    path = args.fns[0]
    if args.inplace:
        dst = path
    else:
        dst = args.fns[1]

    engine = args.engine

    cont = add_md_toc(path, engine)

    with open(dst, 'w') as f:
        f.write(cont)
