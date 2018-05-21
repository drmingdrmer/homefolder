#!/bin/sh
git log --format='%cd' | awk '{ print $4 }' | awk -F: '{print $1}' | sort | uniq -c | awk '{print $2 " " $1}' | eplot -d
