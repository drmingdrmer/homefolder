#!/bin/bash


if [ -d /dev/shm ] && [ ! -d $HOME/tmp ];then
    mkdir -p /dev/shm/xptmp

    rm $HOME/tmp -rf
    ln -s /dev/shm/xptmp $HOME/tmp

    if [ -f $HOME/local.shm.utilize.sh ];then
        . $HOME/local.shm.utilize.sh
    fi

fi
