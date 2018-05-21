#!/bin/sh

# git log 2139d78.. --pretty=tformat: --numstat                       | awk -v k=$k '{i+=$1;j-=$2} END {print " +"i" "j " " (i-j)}'  | column -t
# git log 2139d78.. --pretty=tformat: --numstat --author=jiancheng.he | awk -v k=$k '{i+=$1;j-=$2} END {print " +"i" "j " " (i-j)}'  | column -t
# git log 2139d78.. --pretty=tformat: --numstat --author=hejiancheng  | awk -v k=$k '{i+=$1;j-=$2} END {print " +"i" "j " " (i-j)}'  | column -t
# git log 2139d78.. --pretty=tformat: --numstat --author=何建成       | awk -v k=$k '{i+=$1;j-=$2} END {print " +"i" "j " " (i-j)}'  | column -t

git ls | while read fn; do
    git blame "$fn" \
        | grep "韩晓攀" \
        | grep -v "2139d78\|5b3afe1\|b3e1560\|d782232\|f292b9e\|1462e53"

        # | grep "hejiancheng\|jiancheng.he\|何建成" \
        # | grep "Rijian Jiang\|蒋日健" \
        # | grep "Shuoqing Ding\|丁硕青" \
        # | grep "xiaoshiliang\|肖士良" \
        # | grep "张炎泼" \
        # | grep "易榜宇" \
        # | grep "韩晓攀" \
        # | grep "xiaojiang" \

done | wc

# 总提交行数: 20454
# 丁硕青:      9487
# 何建成:      6383
# 肖世良:      1527
# 蒋日建:      1077
