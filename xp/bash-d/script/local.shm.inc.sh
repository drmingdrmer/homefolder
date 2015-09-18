#!/bin/sh


link_to_home_tmp()
{
    local targetName=$1
    local linkName=$2

    if [ -d $HOME/tmp/$targetName ];then
        echo ;
    else
        mkdir -p $HOME/tmp/$targetName
        rm $linkName -rf
        ln -s $HOME/tmp/$targetName $linkName
    fi
}


