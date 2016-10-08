#!/bin/sh

iptables -F INPUT

iptables -A INPUT -p icmp -j DROP

# ftp
iptables -A INPUT -p tcp --dport 21 -j ACCEPT
# sshd
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
# http
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 8000 -j ACCEPT
iptables -A INPUT -p tcp --dport 8001 -j ACCEPT
# https
iptables -A INPUT -p tcp --dport 443 -j ACCEPT
# svn
iptables -A INPUT -p tcp --dport 3690 -j ACCEPT
# rsync
iptables -A INPUT -p tcp --dport 873 -j ACCEPT
# redis
iptables -A INPUT -p tcp -s 127.0.0.1 --dport 6379 -j ACCEPT

# pptpd
iptables -A INPUT -p tcp --dport 1723 -j ACCEPT
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

# drop all other tcp connection
iptables -A INPUT -p tcp --syn -j DROP


iptables -L -n
