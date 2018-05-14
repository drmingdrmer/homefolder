#!/bin/sh

s=x
systemctl stop $s
systemctl disable $s
rm /etc/systemd/system/$s
rm /etc/systemd/system/$s
systemctl daemon-reload
systemctl reset-failed
