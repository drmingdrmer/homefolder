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
    for p in "" /usr /usr/local /opt/local ~/local ~ ~/xp/bash-d;do

        for binfolder in sbin bin; do
            p2=:$p/$binfolder
            if echo $PATH | grep -q "$p2:"
            then
                :
            else
                PATH=$p2$(echo $PATH | awk -v rep=$p2 -F: '{ gsub(rep, ""); print $0; }')
            fi
        done

        # # /etc/mdm/Xsession complain "Bad substitute" for following lines
        # PATH=:$p/sbin${PATH//:$p\/sbin/}
        # PATH=:$p/bin${PATH//:$p\/bin/}
    done

    # MacPorts Installer addition on 2012-09-23_at_22:32:56: adding an appropriate PATH variable for use with MacPorts.
    export PATH=/usr/local/opt/ipython@5/bin:$PATH
    export PATH=/opt/local/bin:$PATH
    export PATH=/opt/local/sbin:$PATH
    # Finished adapting your PATH environment variable for use with MacPorts.

    export PATH="$HOME/.cargo/bin:$PATH"

    PATH=${PATH//::/:}
    PATH=${PATH#:}
    PATH=${PATH%:}
    export PATH
}
