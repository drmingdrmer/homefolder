#!/usr/bin/env python3
# coding: utf-8

import sys
import re
from urllib.parse import unquote

if __name__ == "__main__":
    cmd = sys.argv[1]
    if cmd == 'extract-title':
        url = sys.argv[2]
        g = re.search(r'https://(.*?).wikipedia.org/wiki/(.*)', url)
        if g:
            lang = g.group(1)
            title = g.group(2)

            print(title)
        else:
            raise ValueError("invalid wikipedia url: " + url)

#  https://zh.wikipedia.org/wiki/%E5%8F%AF%E5%88%86%E6%89%A9%E5%BC%A0
#  title="%E5%8F%AF%E5%88%86%E6%89%A9%E5%BC%A0"
#  curl  "https://zh.wikipedia.org/w/api.php?format=json&action=parse&format=json&prop=text&page=$title" | jq -r '.parse.text["*"]' > src.html
    
