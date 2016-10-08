#!/bin/bash

# or vim /etc/sysctl.conf
echo 1 > /proc/sys/net/ipv4/ip_forward 

iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE
# iptables -A FORWARD -i wlan0 -o vth0 -m state --state RELATED,ESTABLISHED -j ACCEPT
# iptables -A FORWARD -i vth0 -o wlan0 -j ACCEPT

