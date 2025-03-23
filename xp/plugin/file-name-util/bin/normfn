#!/bin/sh

usage()
{
    echo "$0 bla bla"
    echo "convert all arguments to valid all-lower normalized file name"
    echo ' - replace non word char with -'
    echo ' - convert to lower case'
}

# join lines:
# awk '{printf "%s ", $0}'
normalized=$(echo "$*" | awk '{printf "%s ", $0}' | awk '{
    gsub(/[^a-zA-Z0-9]/, "-", $0);
    gsub(/--*/, "-", $0);
    gsub(/^--*/, "", $0);
    gsub(/--*$/, "", $0);
    print tolower($0);
}')

# BEGIN{FS=OFS="-"} - 设置输入和输出的字段分隔符为连字符
# for(i=1;i<=NF;i++) - 循环处理每个字段
# $i=toupper(substr($i,1,1)) substr($i,2) - 将每个字段的第一个字符转为大写，然后与剩余部分拼接
# 最后的 1 是 awk 的简写方式，表示输出当前处理的行
normalized=$(echo "$normalized" | awk 'BEGIN{FS=OFS="-"} {for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)} 1')

echo "$normalized"
printf "%s" "$normalized" | set-clipboard
