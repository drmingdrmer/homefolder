#!/bin/sh

LOG_FILE=${LOG_FILE-/dev/null}


# color definitions {{{
Black="$(tput -T linux setaf 0)"
BlackBG="$(tput -T linux setab 0)"
DarkGrey="$(tput -T linux bold ; tput -T linux setaf 0)"
LightGrey="$(tput -T linux setaf 7)"
LightGreyBG="$(tput -T linux setab 7)"
White="$(tput -T linux bold ; tput -T linux setaf 7)"
Red="$(tput -T linux setaf 1)"
RedBG="$(tput -T linux setab 1)"
LightRed="$(tput -T linux bold ; tput -T linux setaf 1)"
Green="$(tput -T linux setaf 2)"
GreenBG="$(tput -T linux setab 2)"
LightGreen="$(tput -T linux bold ; tput -T linux setaf 2)"
Brown="$(tput -T linux setaf 3)"
BrownBG="$(tput -T linux setab 3)"
Yellow="$(tput -T linux bold ; tput -T linux setaf 3)"
Blue="$(tput -T linux setaf 4)"
BlueBG="$(tput -T linux setab 4)"
LightBlue="$(tput -T linux bold ; tput -T linux setaf 4)"
Purple="$(tput -T linux setaf 5)"
PurpleBG="$(tput -T linux setab 5)"
Pink="$(tput -T linux bold ; tput -T linux setaf 5)"
Cyan="$(tput -T linux setaf 6)"
CyanBG="$(tput -T linux setab 6)"
LightCyan="$(tput -T linux bold ; tput -T linux setaf 6)"
NC="$(tput -T linux sgr0)" # No Color
# }}}

err()
{ #{{{
    local msg="$LightRed[ ERROR ]$NC $@"
    echo "$msg"
    local msg="[`/bin/date +"%F %T"`][ ERROR ] $@"
    echo "$msg" >> ${LOG_FILE}
} #}}}

ok()
{ #{{{
    local msg="${LightGreen}[ OK ]$NC $@"
    echo "$msg"
    local msg="[`/bin/date +"%F %T"`][ OK ] $@"
    echo "$msg" >> ${LOG_FILE}
} #}}}

info()
{ #{{{
    local msg="$Yellow[ INFO ]$NC $@"
    echo "$msg"
    local msg="[`/bin/date +"%F %T"`][ INFO ] $@"
    echo "$msg" >> ${LOG_FILE}
} #}}}


has_command()
{ #{{{
    which $1 2>/dev/null 1>/dev/null
} #}}}

date_epoch()
{ #{{{
    # date format must be "yyyy-mm-dd[ HH[:MM]]"
    date +%s -d "$1"
} #}}}

rand()
{ #{{{
    local ndig=${1-4}
    date +%N | cut -c 0-$ndig
} #}}}

local_ip()
{ #{{{
    local tp=${1-ex}
    if [ "$tp" == "ex" ]; then
        /sbin/ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}' |  grep -v "^172\.\|^10\."
    else
        /sbin/ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}' | grep "^172\.\|^10\."
    fi
} #}}}

__cmds_on_exit__=""
on_exit()
{ #{{{
    # "trap" overrides commands previously set. This is why on_exit here
    local cmd=$*

    if [ "x$__cmds_on_exit__" == "x" ];then
        __cmds_on_exit__=$cmd
    else
        __cmds_on_exit__="$__cmds_on_exit__; $cmd"
    fi

    trap "$__cmds_on_exit__" 0 2 3 15
} #}}}

single_proc()
{ #{{{
    local lockName=$1
    local lockFile=/tmp/$lockName


    if mkdir $lockFile; then
        on_exit "rm -rf $lockFile"
        return 0
    else
        echo `date +"%F %T"` " Another Process is ruuning, exit" >&2
        exit
    fi

} #}}}


save_tmp()
{ #{{{
    local fn=$1

    echo -en "" > $fn
    while shift; do
        echo "$1" >> $fn
    done
} #}}}

load_tmp()
{ #{{{
    local fn=$1

    if [ -f $fn ]; then
        . $fn
        return 0
    else
        return 1
    fi
} #}}}

exit_if_inexist()
{ #{{{
    if [ -f $1 ]; then
        ok "Exist: $1"
    else
        err "Exit because no such file: $1"
        exit 1
    fi
} #}}}


load_scanning_st()
{ #{{{
    # output is 3 global variables:
    #   _inode       # indoe of the $statsFn
    #   _offset      # offset where last read ends
    local statsFn=$1
    local logfn=$2
    local statsFolder=${statsFn%/*}


    exit_if_inexist $logfn


    mkdir -p "$statsFolder"

    currentInode=`stat -c %i $logfn`
    currentSize=`stat -c %s $logfn`


    _sizeReadTmpFN=/tmp/`rand 4`
    _inode=0
    _offset=0


    load_tmp $statsFn


    if [ "$_inode" != "$currentInode" ]; then
        _inode=$currentInode
        _offset=0
    fi

    if [ "$_offset" -gt "$currentSize" ];then
        _offset=0
    fi


    # auto save and cleanup
    on_exit "save_scanning_st $statsFn"

} #}}}

save_scanning_st()
{ #{{{
    local statsFn=$1
    local statsFolder=${statsFn%/*}

    dumpSize=`cat $_sizeReadTmpFN`
    let _offset=_offset+dumpSize



    save_tmp $statsFn "_inode=$_inode" "_offset=$_offset"

    rm -rf $_sizeReadTmpFN
} #}}}

svn_rev()
{ #{{{
    local dir=$1
    svn info $dir | grep -v "^$" | tail -n2 |head -n1 | awk '{print $NF}'
} #}}}

