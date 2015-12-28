[ "x$__BASHRC__" == "x" ] && { __BASHRC__=1; } || { return; }

d()
{
    return 0
    echo $(gdate +"%s.%N") "$@"
}
parse_git_branch()
{
   git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/' 
}
ps_pwd()
{
    local LightBlue="$(tput bold ; tput setaf 4)"
    local NC="$(tput sgr0)" # No Color
    local height=$(tput lines)

    local cwd="${PWD#$HOME}"
    if test ".$cwd" != ".$PWD"; then
        cwd="~$cwd"
    fi
    test "$height" -ge 10 \
        && echo "
$LightBlue$cwd$NC" \
        || echo " $LightBlue$cwd$NC"
}
init_prompt()
{
    Red="$(tput setaf 1)"
    Green="$(tput setaf 2)"
    LightGreen="$(tput bold ; tput setaf 2)"
    Brown="$(tput setaf 3)"
    Yellow="$(tput bold ; tput setaf 3)"
    LightBlue="$(tput bold ; tput setaf 4)"
    NC="$(tput sgr0)" # No Color
    d end color

    PROMPT_COMMAND='echo -ne "\033]0;${mainip}\007"'

    local ps="$Green\u.\h$NC"
    ps=$ps"$Yellow${eth0_ip}$NC"
    # ps=$ps" $Red[\d \t]$NC"
    ps=$ps".\j"
    ps=$ps" $LightGreen\$(parse_git_branch)$NC:"
    ps=$ps"\$(ps_pwd)\n"
    export PS1="$ps"
    d end ps1
}
init_plugin()
{
    source_dir "$XPBASE/rc/bash-plugin-rc"
    d end rc

    shname=bash

    for plg in $(ls $XPBASE/plugin/); do

        plgpath="$XPBASE/plugin/$plg"

        rcpath="$plgpath/rc"
        if [ -d "$rcpath" ]; then
            cwd=$(pwd)
            cd $plgpath
            . $rcpath/${shname}rc
            cd $cwd
        fi

        binpath="$plgpath/bin"
        if [ -d "$binpath" ]; then
            export PATH=$PATH:$binpath
        fi


        cmplpath="$plgpath/complete"
        if [ -d "$cmplpath" ]; then
            for cmpl in $(ls $cmplpath/*.$shname); do
                . $cmpl
            done
        fi

    done

    source_dir "$XPBASE/rc/bash-plugin-init"
    d end plug-init
}
source_dir()
{
    local dir="$1"
    for fn in `ls $dir/*`; do
        source $fn
    done
}

. ~/.profile
d end profile

. $XPBASE/inc/util.sh
d end util

if [ -z $LANG ]; then
    export LANG=en_US.utf-8
    export LC_ALL=en_US.utf-8
fi

os=$(os_detect)
export OS=$os

. $XPBASE/script/tmp.to.shm.sh
d end tmp

. $XPBASE/rc/alias
d end alias

export EDITOR=vim
export SVN_EDITOR='vim'
export HISTSIZE=50000
export HISTCONTROL=ignoreboth
[ -d $HOME/xp/gopath ] && { export GOPATH=$HOME/xp/gopath; export PATH=$PATH:$GOPATH/bin; }

export PYTHONPATH=/usr/lib/python2.6/site-packages/:$PYTHONPATH
export HISTIGNORE="ll:ls"
export GREP_COLORS="ms=01;33:mc=01;31:sl=0;33:cx=:fn=35:ln=32:bn=32:se=36"

if [ "$os" = "linux" ] ; then
    eth0_ip=`/sbin/ifconfig | grep 'inet addr:' | grep -v "127.0.0.1"  | awk '/inet addr/{i = i " <" substr($2, 6) ">"} END{print i}'`
    mainip=`/sbin/ifconfig | grep 'inet addr:' | grep -v "127.0.0.1" | grep -v 'addr:10\.\|addr:172.16' | head -n1 | awk '/inet addr/{i = i substr($2, 6) } END{print i}'`
elif [ "$os" = "bsd" ]; then
    eth0_ip=`/sbin/ifconfig | grep "inet"|awk -F "." '{print $3"."$4}'| awk '{print $2}' | head -n 3`
elif [ "$os" == "mac" ]; then
    eth0_ip=`ifconfig  | grep '\binet\b' | grep -v '127.0.0.1' | awk '/inet /{i = i " <" substr($2, 1) ">"} END{print i}'`
    mainip=`ifconfig  | grep '\binet\b' | grep -v '127.0.0.1' | grep -v ' 10\.\| 172.16' | head -n1 | awk '{print $2}'`
else
    eth0_ip="unknown"
    mainip="unknown"
fi
d end os

init_prompt
init_plugin

if which brew >/dev/null 2>/dev/null && [ -f $(brew --prefix)/etc/bash_completion ]; then
    . $(brew --prefix)/etc/bash_completion
fi
d end brew

# TODO when to fix GOROOT?
# [ ".$GOROOT" = "." ] && { export GOROOT=/usr/local/go; export PATH=$PATH:$GOROOT/bin; }
