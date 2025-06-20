[ "x$__BASHRC__" == "x" ] && { __BASHRC__=1; } || { return; }

git="$(which git)"

d()
{
    return 0
    echo $(gdate +"%s.%N") "$@"
}
parse_git_branch()
{
   $git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
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
    test "$height" -gt 10 \
        && echo "
$LightBlue$cwd$NC" \
        || echo " $LightBlue$cwd$NC"
}
init_prompt()
{
    [ -t 1 ] || return 0

    Red="$(tput setaf 1)"
    Green="$(tput setaf 2)"
    LightGreen="$(tput bold ; tput setaf 2)"
    Brown="$(tput setaf 3)"
    Yellow="$(tput bold ; tput setaf 3)"
    LightBlue="$(tput bold ; tput setaf 4)"
    NC="$(tput sgr0)" # No Color
    d end color

    # PROMPT_COMMAND='echo -ne "\033]0;${mainip}\007"'
    # export PROMPT_COMMAND='screen -X title "$(basename "$(git rev-parse --show-toplevel 2>/dev/null)"):$(git symbolic-ref --short HEAD 2>/dev/null)" >/dev/null'
    export PROMPT_COMMAND='savepwd'

    local ps="$Green\u \h$NC"
    ps=$ps"$Yellow${eth0_ip}$NC"
    ps=$ps".\j"
    ps=$ps" $LightGreen\$(parse_git_branch 2>/dev/null || $git branch --no-color 2> /dev/null)$NC"
    ps=$ps" -> $Red\$($git config --get branch.\$($git symbolic-ref --short HEAD 2>/dev/null).remote 2>/dev/null)/$NC"
    ps=$ps"$Brown\$($git config --get branch.\$($git symbolic-ref --short HEAD 2>/dev/null).merge 2>/dev/null | sed 's/^refs\/heads\///')$NC"
    ps=$ps" \t:"
    ps=$ps"\$(ps_pwd 2>/dev/null || { echo; pwd; })\n"
    ps=$ps"\$(savepwd)"
    export PS1="$ps"
    d end ps1
}
init_plugin()
{
    shname=bash

    for plg in $(ls $XPBASE/plugin/); do

        plgpath="$XPBASE/plugin/$plg"

        if [ -d "$plgpath/rc" ]; then
            cwd=$(pwd)
            cd $plgpath
            . $plgpath/rc/${shname}rc
            cd $cwd
        fi

        if [ -d "$plgpath/bin" ]; then
            export PATH=$plgpath/bin:$PATH
        fi


        cmplpath="$plgpath/complete"
        if [ -d "$cmplpath" ]; then
            for cmpl in $(ls $cmplpath/*.$shname); do
                . $cmpl
            done
        fi

    done
}

init_v2_plugin()
{
    shname=bash

    for plg in $(ls $XP_DIR/plugin/); do

        plgpath="$XP_DIR/plugin/$plg"

        # rc

        if [ -d "$plgpath/rc" ]; then
            cwd=$(pwd)
            cd $plgpath
            . $plgpath/rc/${shname}rc
            cd $cwd
        fi

        # bin

        if [ -d "$plgpath/bin" ]; then
            export PATH=$plgpath/bin:$PATH
        fi

        # complete

        cmplpath="$plgpath/complete"
        if [ -d "$cmplpath" ]; then
            for cmpl in $(ls $cmplpath/*.$shname); do
                . $cmpl
            done
        fi

    done
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

. $HOME/xp/bash-d/inc/util.sh
d end util

if [ -z $LANG ]; then
    export LANG=en_US.utf-8
    export LC_ALL=en_US.utf-8
fi

os=$(os_detect)
export OS=$os

mkdir -p $HOME/tmp
d end tmp

. $XPBASE/rc/alias
d end alias

# force 16-colors term
export TERM=xterm

export EDITOR=vim
export HISTSIZE=50000
export HISTCONTROL=ignoreboth
export HISTTIMEFORMAT="%Y/%m/%d %H:%M:%S "


export HISTIGNORE="l:la:ll:ls:gl"
export GREP_COLORS="ms=01;33:mc=01;31:sl=0;33:cx=:fn=35:ln=32:bn=32:se=36"

if [ "$os" = "linux" ] ; then
    eth0_ip=`echo $(/sbin/ifconfig  | grep 'inet \(addr:\)\?'| grep -v '127.0.0.1' |  grep -v 'Mask:255.255.255.255' | awk '{gsub("addr:","",$2); print " <"$2">"}')`
    mainip=`/sbin/ifconfig | grep 'inet addr:' | grep -v "127.0.0.1" | grep -v 'addr:10\.\|addr:172.16' | head -n1 | awk '/inet addr/{i = i substr($2, 6) } END{print i}'`
elif [ "$os" = "bsd" ]; then
    eth0_ip=`/sbin/ifconfig | grep "inet"|awk -F "." '{print $3"."$4}'| awk '{print $2}' | head -n 3`
elif [ "$os" == "mac" ]; then
    eth0_ip=`ifconfig  | grep '\binet\b' | grep -v '127.0.0.1' | awk '/inet/{i = i " <" substr($2, 1) ">"} END{print i}'`
    mainip=`ifconfig  | grep '\binet\b' | grep -v '127.0.0.1' | grep -v ' 10\.\| 172.16' | head -n1 | awk '{print $2}'`
else
    eth0_ip="unknown"
    mainip="unknown"
fi
d end os

init_prompt

source_dir "$XPBASE/rc/bash-plugin-rc"
d end rc

init_plugin

init_v2_plugin

source_dir "$XPBASE/rc/bash-plugin-init"
d end plug-init

if which brew >/dev/null 2>/dev/null && [ -f $(brew --prefix)/etc/bash_completion ]; then
    . $(brew --prefix)/etc/bash_completion
fi
d end brew

while read p; do
    if [ -z "$p" ] || [ "${p:0:1}" == "#" ]; then
        continue
    fi
    [ -f "$p" ] && source "$p"
done <<-END
# Optional local bashrc
$HOME/.xp-bashrc

# added by travis gem
$HOME/.travis/travis.sh
END

if which gocomplete >/dev/null 2>/dev/null; then
    complete -C gocomplete go
fi

# workaround: tmux does not understand quote.
# need to do it in vim because vim does not trigger shell
#   autocmd CursorHold,CursorHoldI * !savepwd
# Also PS1 and PROMPT_COMMAND is set up there.
cd "$(cat $HOME/xp/session/savepwd/saved)"

# source $HOME/xp/tmp/subrepo/git-subrepo/.rc

# export PATH="$HOME/xp/vcs/github.com/jwiegley/git-scripts:$PATH"

export PATH="$HOME/.basher/bin:$PATH"
eval "$(basher init -)"

# Wasmer
export WASMER_DIR="/Users/drdrxp/.wasmer"
[ -s "$WASMER_DIR/wasmer.sh" ] && source "$WASMER_DIR/wasmer.sh"

# Required by `brew install nvm`
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# trojan
tj_sock5="socks5://127.0.0.1:1080"

enable_proxy()
{
    local port=7890
    export HTTP_PROXY=http://127.0.0.1:$port; export HTTPS_PROXY=http://127.0.0.1:$port; export ALL_PROXY=socks5://127.0.0.1:$port
}

proxy_sh()
{

    HTTP_PROXY=http://127.0.0.1:58591 HTTPS_PROXY=http://127.0.0.1:58591 ALL_PROXY=socks5://127.0.0.1:51837 bash
}

p3venv()
{
    # make a python3 virtual env in current dir
    python3 -m venv .
    . ./bin/activate
    touch requirements.txt
}

secsh()
{
    printf "enter des-ede3-cbc decryption password:"
    read -s pass
    SECPASS="$pass" bash
}


tmsh()
{
    # to shared:
    # tmux new -s shared
    local name=shared

    # make current tmux pane a shared pane
    local ww=$(tmux display -p "#{window_width}")
    local ww=$(($ww * 40 / 100))
    local ww=60
    tmux resize-pane -x $ww

    unset TMUX
    tmux attach -t $name

    # to detach:
    # tmux detach
}

dtdir()
{
    local msg=${1-x}
    local d="$(date "+%Y-%m-%d-%H-%M-$msg")"

    mkdir $d
    cd $d
}

rmdtdir()
{
    # First ensure current directory is in the format:
    # ~/tt/2025-06-15-10-00-**

    # Check if parent directory is 'tt'
    local parent_dir="$(dirname "$PWD")"
    if [[ "$parent_dir" != "$HOME/tt" ]]; then
        echo "Not in a '~/tt' subdirectory, skipping destruction"
        return
    fi

    # If current directory is not a date-time directory, return directly
    local current_dir=$(basename "$PWD")
    if [[ ! "$current_dir" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{2}-[0-9]{2}- ]]; then
        echo "Not in a date-time directory, skipping destruction"
        return
    fi

    # Confirm destruction with user
    echo "About to destroy directory: $current_dir"
    echo "Are you sure? (y/N)"
    read -r confirmation
    
    if [[ "$confirmation" != "y" && "$confirmation" != "Y" ]]; then
        echo "Destruction cancelled"
        return
    fi
    
    cd ..

    rm -rf $current_dir

}

. "$HOME/.cargo/env"

# add this or git commit with signing does not work
export GPG_TTY=$(tty)
