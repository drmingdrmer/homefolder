#!/bin/sh

# first time run:
# rclone config

# brew install rclone

# require proxy maybe
rclone copy -v 'onedrive:/Pictures/Camera Roll' 'googlephotos:upload'
