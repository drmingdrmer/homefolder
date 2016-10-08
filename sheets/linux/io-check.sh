#!/bin/sh

/etc/init.d/syslog stop
echo 1 > /proc/sys/vm/block_dump
sleep 60

dmesg | awk '/(READ|WRITE|dirtied)/ {process[$1]++} END {for (x in process) \
print process[x],x}' |sort -nr |awk '{print $2 " " $1}' | \

head -n 10
echo 0 > /proc/sys/vm/block_dump
/etc/init.d/syslog start
