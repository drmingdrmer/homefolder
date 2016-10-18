#!/bin/sh

# -N without header
# -s without frame
/usr/local/mysql-5.7.13/bin/mysql --socket=/tmp/mysql-3309.sock -e "show slave status" -Ns
