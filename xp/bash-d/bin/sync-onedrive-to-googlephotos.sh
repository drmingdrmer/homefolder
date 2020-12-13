#!/bin/sh

# first time run:
# rclone config
rclone copy -v 'onedrive:/Pictures/Camera Roll' 'googlephotos:upload'
