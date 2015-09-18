#!/bin/sh

if [ "x$__UTIL_INITED__" != "x"  ]; then
    return
fi
__UTIL_INITED__=1

os_detect()
{
    case $(uname -s) in
        Linux)
            os=linux ;;
        *[bB][sS][dD])
            os=bsd ;;
        Darwin)
            os=mac ;;
        *)
            os=unix ;;
    esac
    echo $os
}

env_init_path()
{
    PATH=:$PATH:
    for p in "" /usr /usr/local /opt/local ~ ~/xp/bash-d;do

        for binfolder in sbin bin; do
            p2=:$p/$binfolder
            PATH=$p2$(echo $PATH | awk -v rep=$p2 -F: '{ gsub(rep, ""); print $0; }')
        done

        # # /etc/mdm/Xsession complain "Bad substitute" for following lines
        # PATH=:$p/sbin${PATH//:$p\/sbin/}
        # PATH=:$p/bin${PATH//:$p\/bin/}
    done
    PATH=${PATH//::/:}
    PATH=${PATH#:}
    PATH=${PATH%:}
    export PATH
}
