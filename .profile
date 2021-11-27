if [ "x$__XP_PROFILE__" != "x" ]; then
    return
fi
__XP_PROFILE__=1

XPBASE=$HOME/xp/bash-d

export XPBASE

. $HOME/xp/bash-d/inc/util.sh
env_init_path

if [ "$BASH" ]; then
    for rcfn in ~/.bashrc; do
        if [ -f $rcfn ]; then
            . $rcfn
        fi
    done
fi


[ -t 1 ] && mesg y

# vim: ft=sh

export PATH="$HOME/.cargo/bin:$PATH"


# m1 mac brew
if [ -f /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi


# from brew info llvm:

LDFLAGS="-L/usr/local/opt/llvm/lib -Wl,-rpath,/usr/local/opt/llvm/lib"
export PATH="/usr/local/opt/llvm/bin:$PATH"
export LDFLAGS="-L/usr/local/opt/llvm/lib"
export CPPFLAGS="-I/usr/local/opt/llvm/include"
