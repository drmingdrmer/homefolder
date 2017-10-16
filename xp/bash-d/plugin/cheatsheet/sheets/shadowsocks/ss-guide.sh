#!/bin/sh

yum install -y python27-pip

pip install shadowsocks

_ip=$(/sbin/ifconfig  | grep 'inet \(addr:\)\?'| grep -v '127.0.0.1' |  grep -v 'Mask:255.255.255.255' | head -n1 | awk '{gsub("addr:","",$2); print $2}')

mkdir ss

cat >ss/ssserver.json<<-END
{
    "server":        "$_ip",
    "server_port":   8388,
    "local_address": "127.0.0.1",
    "local_port":    1080,
    "password":      "3432jk4l3",
    "timeout":       300,
    "method":        "aes-256-cfb",
    "fast_open":     false
}
END

nohup ssserver -c ss/ssserver.json -d start &
