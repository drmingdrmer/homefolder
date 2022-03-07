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

    while read p; do
        if [ -z "$p" ] || [ "${p:0:1}" == "#" ]; then
            continue
        fi
        [ -d "$p" ] && { export PATH="$p:$PATH"; }
    done <<-END
# python
/usr/local/opt/ipython@5/bin
$HOME/Library/Python/3.7/bin

# brew:
# If you need to have python@3.8 first in your PATH run:
#   echo 'export PATH="/usr/local/opt/python@3.8/bin:$PATH"' >> ~/.profile
# 
# For compilers to find python@3.8 you may need to set:
#   export LDFLAGS="-L/usr/local/opt/python@3.8/lib"
# 
# For pkg-config to find python@3.8 you may need to set:
#   export PKG_CONFIG_PATH="/usr/local/opt/python@3.8/lib/pkgconfig"
#
/usr/local/opt/python@3.8/bin

# rust
$HOME/.cargo/bin

# ruby gem
/usr/local/lib/ruby/gems/2.6.0/bin
/usr/local/lib/ruby/gems/2.7.0/bin

# perl
/usr/local/Cellar/perl/5.30.1/bin
/opt/homebrew/Cellar/perl/5.34.0/bin

# locally installed npm module
$HOME/node_modules/.bin

/usr/local/opt/opencv3/bin

/usr/local/Cellar/mysql-client/8.0.26/bin/

# add local bin for this computer: eg. Darwin-x86_64-bin
$HOME/xp/bash-d/$(uname -s)-$(uname -m)-bin
END

# golang paths
while read p; do
    if [ -z "$p" ] || [ "${p:0:1}" == "#" ]; then
        continue
    fi
    [ -d "$p/bin" ] && {
        export PATH="$p/bin:$PATH"
            export GOROOT="$p"
        }
done <<-END
$HOME/go
$HOME/xp/go
END

export GOPATH=$HOME/xp/vcs/go
export PATH=$GOPATH/bin:$PATH


# on mac: use homebrew ruby:
export PATH="/usr/local/opt/ruby/bin:$PATH"
export LDFLAGS="-L/usr/local/opt/ruby/lib"
export CPPFLAGS="-I/usr/local/opt/ruby/include"
export PKG_CONFIG_PATH="/usr/local/opt/ruby/lib/pkgconfig"


    PATH=${PATH//::/:}
    PATH=${PATH#:}
    PATH=${PATH%:}
    export PATH
}
