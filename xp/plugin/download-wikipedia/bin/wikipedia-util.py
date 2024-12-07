#!/usr/bin/env python3
# coding: utf-8

import sys
import re
from urllib.parse import unquote

def parse_url(url: str):

    g = re.search(r'https://(.*?).wikipedia.org/wiki/(.*)', url)
    if g:
        lang = g.group(1)
        escaped_title = g.group(2)
        title = unquote(escaped_title)
    else:
        raise ValueError("invalid wikipedia url: " + url)

    return {"lang": lang,
            "title": title,
            "escaped_title": escaped_title,
    }



if __name__ == "__main__":
    cmd = sys.argv[1]
    if cmd == 'extract-title':
        url = sys.argv[2]
        parsed = parse_url(url)
        print(parsed["escaped_title"])
    elif cmd == 'extract-lang':
        url = sys.argv[2]
        parsed = parse_url(url)
        print(parsed["lang"])

    else:
        raise ValueError("invalid command: " + cmd)
