#!/bin/sh

./bin/mysqlbinlog  /data1/mysql-3308/mysql-bin.000001 \
    -v \
    --start-datetime="$(date +"%F %T" -d "-10 seconds")"
