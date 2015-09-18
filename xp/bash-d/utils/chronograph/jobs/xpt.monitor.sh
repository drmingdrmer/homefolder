#!/bin/bash


xset act dumpPage
curl "http://www.vim.org/scripts/script.php?script_id=2611" > .tmp

# Rating <b>118/36</b>,
# Downloaded by 551  </td>

rate=`grep "Rating" .tmp | sed 's/[^0-9\/]//g' | awk -F/ '{print $1}'`
post=`grep "Rating" .tmp | sed 's/[^0-9\/]//g' | awk -F/ '{print $2}'`
download=`grep "Downloaded by" .tmp | sed 's/[^0-9\/]//g' | awk -F/ '{print $1}'`


echo `date +"%F=%T"` $rate $post $download $frame >> xpt.log

rm .tmp

