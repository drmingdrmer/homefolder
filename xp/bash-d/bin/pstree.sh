#!/bin/sh

ps -eo pid,ppid,command | '
{
    _pid=$1
    _ppid=$2
    all=$0

    pid=sprintf("%5s", _pid)
    ppid=sprintf("%5s", _ppid)

    parents[pid] = ppid
    gsub("^ *[0-9]* *[0-9]* *", "", all)
    info[pid] = all
}

END {
    for (pid in parents) {
        s = pid
        p=pid
        while ( p != 0 ) {
            s = parents[p]" "s
            p = parents[p]
        }
        rows[s] = parents[pid]
    }

    asorti(rows)
    for (i in rows) {
        sub("......", "", rows[i])
        # print rows[i]
    }

    for (i in rows) {
        pid = rows[i]
        gsub(".* ", "", pid)

        padding = rows[i]
        pid=sprintf("%5s", pid)

        print padding, pid"  |  " info[pid]
    }
}'
