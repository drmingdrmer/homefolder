#!/bin/bash

# authorize
curl -u admin:748748 http://10.0.0.1/RST_status.htm | iconv -f gb2312 -t utf-8

# get data
curl -u admin:748748 http://10.0.0.1/RST_status.htm | iconv -f gb2312 -t utf-8 | fgrep 221.223. | awk -F\> '{print $2}' | sed "s/[^0-9.]//g" > ip.txt
