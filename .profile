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


export BREW_BASE=/usr/local

# m1 mac brew: from brew installation instruction
if [ -f /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    export BREW_BASE=/opt/homebrew
fi


export PATH="$BREW_BASE/share/git-core/contrib/diff-highlight:$PATH"


# ==== APPs path ==== 

# from brew info llvm:
LDFLAGS="-L/usr/local/opt/llvm/lib -Wl,-rpath,/usr/local/opt/llvm/lib"
export PATH="/usr/local/opt/llvm/bin:$PATH"
export LDFLAGS="-L/usr/local/opt/llvm/lib"
export CPPFLAGS="-I/usr/local/opt/llvm/include"
. "$HOME/.cargo/env"

# mysql
export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"




# python virtual env
# . $HOME/xp/py3virtual/dev/bin/activate
. $HOME/xp/py3virtual/p3-11-3/bin/activate


export PATH="$HOME/xp/vcs/github.com/drmingdrmer/gift:$PATH"
alias git='gift --exec-path='"$(git --exec-path)"


# go proxy:
# https://arslan.io/2019/08/02/why-you-should-use-a-go-module-proxy/
export GOPROXY=https://goproxy.cn
