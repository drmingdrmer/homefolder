#!/bin/sh

frm=$1
to=$2

if [ -z "$frm" ] || [ -z "$to" ]; then
    cmd='git-change-remote-user.sh'
    {

    
    cat <<-END
Usage:
    $cmd <from-user> <to-user>

Change all git remote user <from-user> to <to-user>

Before $cmd drdrxp bsc
    git remote -v
    coding  git@git.coding.net:drdrxp/homefolder.git (fetch)
    coding  git@git.coding.net:drdrxp/homefolder.git (push)
    origin  git@github.com:drdrxp/homefolder.git (fetch)
    origin  git@github.com:drdrxp/homefolder.git (push)

After $cmd drdrxp bsc
    git remote -v
    coding  git@git.coding.net:bsc/homefolder.git (fetch)
    coding  git@git.coding.net:bsc/homefolder.git (push)
    origin  git@github.com:bsc/homefolder.git (fetch)
    origin  git@github.com:bsc/homefolder.git (push)
END
    } | grep --color "bsc\|drdrxp\|from-user\|to-user\|^$"

     exit 0
fi

for name in $(git remote); do

    url="$(git remote -v \
        | fgrep '(fetch)' \
        | grep --color "^$name\b" \
        | awk '{print $2}' \
        | grep "\b$frm\b")"

    if [ -z "$url" ]; then
        continue
    fi

    url="$(echo "$url" | gsed 's/\<'$frm'\>/'$to'/')"

    echo $name
    echo $url
    echo git remote set-url "$name" "$url"

done

