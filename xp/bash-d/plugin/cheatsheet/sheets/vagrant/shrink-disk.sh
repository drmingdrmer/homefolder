#!/bin/sh

# Step-1

# fillup all disk with zero
vagrant ssh
sudo dd if=/dev/zero of=wipefile bs=1024x1024; rm wipefile


# Step-2

# virtual box:
VboxManage clonehd old.vdi new.vdi


# vmware:
vmware-vdiskmanager -d /path/to/main.vmdk
vmware-vdiskmanager -k /path/to/main.vmdk


# http://andrewdeponte.com/2013/10/29/shrinking-vagrant-linux-boxes.html
