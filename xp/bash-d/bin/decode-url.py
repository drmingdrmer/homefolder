#!/usr/bin/env python
# coding: utf-8

import sys
from urllib.parse import unquote

if __name__ == "__main__" :
    url = sys.argv[1]
    decoded_url = unquote(url)
    print(decoded_url)
