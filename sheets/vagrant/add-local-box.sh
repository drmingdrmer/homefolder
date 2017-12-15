#!/bin/sh

vagrant box add --name centos72 /Users/drdrxp/xp/Dropbox/Sync/package/vagrant-box/centos-7-2-virtualbox.box

vagrant init centos72

vagrant up


yum update -y
yum install -y \
    vim \
    git \
    net-tools \
