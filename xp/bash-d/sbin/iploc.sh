#!/bin/sh

enc=`env | grep ^LANG | awk -F . '{print $2}'`
# curl -s "http://www.ip138.com/ips.asp?ip=$1&action=2" | iconv -t $enc -f GB18030 | grep "本站主数据"
w3m -dump  "http://www.ip138.com/ips.asp?ip=$1&action=2" 2>/dev/null | grep "本站主数据" | awk -F"：" '{print $2}'
