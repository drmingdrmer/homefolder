#!/bin/sh

set -o errexit

input="${1}"
default_output="${input%.*}-cc-1280x702.mp4"
output="${2-$default_output}"

ffmpeg \
    -i "$input" \
    -vf scale=1280:720,fps=30 \
    -c:v h264_videotoolbox \
    -b:v 1M \
    -c:a aac \
    -b:a 128k \
    -preset medium \
    -threads 0 \
    "$output"

