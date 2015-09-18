#!/bin/sh
diff -rq "$1" "$2" | fgrep -v .svn | awk '/Files/{print "vimdiff "$2 " "$4}'> ~/.tmp.sh
chmod 777 ~/.tmp.sh
~/.tmp.sh
rm ~/.tmp.sh -rf
