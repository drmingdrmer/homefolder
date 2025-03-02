#!/bin/sh

set -o errexit

input="${1}"

output="$(_video_conv_output_name.sh "output-640x" "$input" "$2")"

echo "$input ===> $output"

ffmpeg \
    -i "$input" \
    -vf scale=640:-2,fps=24 \
    -c:v h264_videotoolbox \
    -b:v 0.7M \
    -c:a aac \
    -b:a 96k \
    -preset slower \
    -threads 0 \
    "$output"

