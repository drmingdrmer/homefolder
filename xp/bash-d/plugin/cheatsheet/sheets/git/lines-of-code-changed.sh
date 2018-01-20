#!/bin/sh

git log HEAD~~..master \
    --numstat \
    --pretty="%H" \
    --author='xiaoyu' \
    --since='6 month ago' \
    | awk 'NF==3 {plus+=$1; minus+=$2} END {printf("+%d, -%d\n", plus, minus)}'

# +3183,   -137


for k in `ls`; do ( cd $k; git log  --pretty=tformat: --numstat --since="365 days ago" | awk -v k=$k '{i+=$1;j-=$2} END {print k": +"i" "j ""}'; ) done | column -t
# EzSVG:                   +7      -3
# LuaJIT:                  +
# LuaJIT-test-cleanup:     +
# ansiblekit:              +206    0
# awssign:                 +368    -118
# baishancloud.github.io:  +6796   0
# lrc-erasure-code:        +
# lua-acid:                +27244  -2165
# lua-consistent-hash:     +162    -84
# lua-resty-awsauth:       +472    -91
# lua-resty-s3-client:     +3463   -321
# lua-sharedtable:         +15156  -1237
# lua-std-ffi:             +1740   -64
# luajit2:                 +
# mimetype:                +1000   0
# mysql-devops:            +42871  -5005
# openresty:               +11     -1
# pykit:                   +36861  -5413
# shlib:                   +1313   -134
# stopwatch:               +161    -40
