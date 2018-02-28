#!/bin/sh

perl_path="$(which perl)" && \
    {
        perl_path="$(greadlink -m "$perl_path")"

        perl_dir="$(dirname "$perl_path")"

        if [ -f "$perl_dir/graph-easy" ]; then
            alias graph-easy="$perl_dir/graph-easy"
        fi
    }

