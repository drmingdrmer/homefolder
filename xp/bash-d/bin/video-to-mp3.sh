#!/bin/sh

src_dir="$1"
dst_dir="$2"

if test -z "$src_dir" || test -z "$dst_dir"; then
    echo "usage: ${0##*/} <src_dir> <dst_dir>"
    exit 1
fi

mkdir -p "$dst_dir" || exit 1

for fn in $(find "$src_dir" -type f -name "*")
do
    dst="$dst_dir/${fn%.*}.mp3"
    mkdir -p "$(dirname $dst)"
    ffmpeg -i "$fn" "$dst"
done
