#!/bin/sh

if which greadlink >/dev/null 2>/dev/null; then
    _readlink=greadlink
else
    _readlink=readlink
fi

perl_path="$(which perl)" && \
    {
        perl_path="$($_readlink -m "$perl_path")"

        perl_dir="$(dirname "$perl_path")"

        if [ -f "$perl_dir/graph-easy" ]; then
            alias graph-easy="$perl_dir/graph-easy"
        fi
    }

