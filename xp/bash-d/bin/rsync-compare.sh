#!/bin/bash


# -c	: checksum comparison instead of modify-time and size
# -v	: show detailed info
# -n	: dry run, summary only, no real data transfered
# -r	: recursing
# -l	: link
# -p	: permission
# -g	: group
# -o	: owner
# -D	: --devices

rsync  -cavn --exclude=.* --delete $1 $2
