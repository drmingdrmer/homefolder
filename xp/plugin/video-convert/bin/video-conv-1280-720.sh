#!/bin/sh

set -o errexit

input="${1}"

output="$(_video_conv_output_name.sh "output-1280x720" "$input" $2)"

echo "$input ===> $output"

ffmpeg \
    -i "$input" \
    -vf scale=1280:720,fps=30 \
    -c:v h264_videotoolbox \
    -b:v 2M \
    -c:a aac \
    -b:a 128k \
    -preset medium \
    -threads 0 \
    "$output"

