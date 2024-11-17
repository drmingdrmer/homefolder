#!/bin/sh

set -o errexit

input="${1}"
subtitle_stream="${2}"
output="${input%.*}.ass"

# ffmpeg -i input.mkv -map 0:3 -c copy subtitle.ass
ffmpeg -i "$input" -map "$subtitle_stream" -c copy "$output"
