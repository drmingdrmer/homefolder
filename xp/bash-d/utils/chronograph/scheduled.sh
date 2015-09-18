#!/bin/bash

doit()
{ #{{{

    XPRC=~/.profile
    while [ -h "$XPRC" ]; do XPRC=`readlink "${XPRC}"`; done
    XPRC="$( cd -P "$( dirname "$XPRC" )" && pwd )"

    XPBASE=$( dirname "$XPRC" )

    XpBase=$XPBASE
    ourPath="$XpBase/utils/chronograph"
    local logfn="$ourPath/log"
    local lockfn="$HOME/xp-scheduled.lock"
    local jobDir="$ourPath/jobs"
    local job_enabled="$ourPath/jobs-enabled"


    if [ ! -d "$ourPath" ]; then
        echo "No such folder: '$ourPath'" >&2
        return 1
    fi


    export TERM=xterm
    cd $ourPath

    # stdout, errout
    exec 1>>"$logfn" 2>&1

    # includes
    . $XpBase/inc/colors
    . $XpBase/inc/log.xp

    # lock & unlock
    mkdir "$lockfn" || { xerr "lock failed: '$lockfn' exit"; return 1; }
    trap "rm -rf \"$lockfn\" && xok \"lock removed\"; xstep \"daily scheduled jobs end   **********************\n\n\n\"" 0 2 3 15


    xstep "${Yellow}daily scheduled jobs start ------------------------------------------------$NC"

    # jobs:
    for job in `ls $job_enabled/`; do

        xset job $job act "-"

        xstep "$Yellow About to start$NC"

        ( . "$jobDir/$job" )
        xset job '-' xset act "-"
    done

} #}}}

cmd=$1
case $cmd in
    install)
        :
        ;;
    run)
        doit
        ;;
    *)
        echo "Invalid Command: '$cmd'" >&2
        exit 1
        ;;
esac
