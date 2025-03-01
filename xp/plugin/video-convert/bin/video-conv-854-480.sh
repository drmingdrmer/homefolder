#!/bin/sh

set -o errexit

input="${1}"

output="$(_video_conv_output_name.sh "output-854x480" "$input" $2)"

echo "$input ===> $output"

    # -vf scale=854:480,fps=24 \
ffmpeg \
    -i "$input" \
    -vf scale=854:-2,fps=24 \
    -c:v h264_videotoolbox \
    -b:v 1M \
    -c:a aac \
    -b:a 64k \
    -preset slow \
    -threads 0 \
    "$output"

