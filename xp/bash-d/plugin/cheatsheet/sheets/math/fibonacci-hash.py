#!/usr/bin/env python
# coding: utf-8

# http://www.brpreiss.com/books/opus4/html/page214.html
# 2^16     40503
# 2^32     2654435769
# 2^64     11400714819323198485

fib16 = lambda i: ( i*40503 ) % ( 1 << 16 )
fib32 = lambda i: ( i*2654435769 ) % ( 1 << 32 )
fib64 = lambda i: ( i*11400714819323198485 ) % ( 1 << 64 )
