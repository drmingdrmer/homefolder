#!/bin/sh

path="$(pwd)"

root=$(cd "$(git rev-parse --show-toplevel)";  pwd)

wtpath="${path#$root}"
# echo $path
# echo $root
# echo $wtpath

stat="$(
git ls "$path"  \
    | while read fn; do git blame "$fn" --line-porcelain; done \
    | grep "^author-mail" \
    | awk '{gsub(/[<>]|@.*/, "",  $2); print "@"$2}' \
    | awk '{a[$0] += 1} END { for (nm in a) { print a[nm] " " nm } }' \
    | sort -rn \
    | head -n4
)"

owners="$(echo "$stat" | awk '{print $2}')"

# echo "stat:"
# echo "$stat"

echo "$wtpath/** $(echo $owners)"
