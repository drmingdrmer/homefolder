#!/bin/sh

git log HEAD~~..master \
    --numstat \
    --pretty="%H" \
    --author='xiaoyu' \
    --since='6 month ago' \
    | awk 'NF==3 {plus+=$1; minus+=$2} END {printf("+%d, -%d\n", plus, minus)}'

# +3183,   -137
