#!/bin/sh

# back up netease music in dir ./src to dir ./dst

# 1. copy all file to tmp dir
# 2. convert ncm to mp3
# 3. dedup
# 4. copy from tmp to dst

set -o errexit

./convert-ncm-to-mp3.sh ./src keep

rsync -Rauv src/./*.mp3 dst/./
rsync -Rauv src/./*.flac dst/./

exit

./convert-ncm-to-mp3.sh ./dst-tmp

python3 dedup.py ./dst-tmp

mv dst-tmp/./*.mp3 dst/./

