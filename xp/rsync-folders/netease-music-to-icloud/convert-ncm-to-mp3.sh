#!/bin/sh

set -o errexit

dir="$1"

to_delete="$2"

if [ ".$dir" = "." ]; then
    echo "usage: $0 ./dir_contains_ncm"
    exit 1
fi

if [ ".$to_delete" = "." ]; then
    to_delete="keep"
fi

# require ncmdump
# https://github.com/taurusxin/ncmdump
cd ./$dir
ls *.ncm | while read a; do
    if [ -f "${a%.ncm}.mp3" ]; then
        echo "exists: ${a%.ncm}.mp3"
    else
        ncmdump "$a"
    fi

    if [ ".$to_delete" = ".del" ]; then
        rm "$a"
    fi
done
