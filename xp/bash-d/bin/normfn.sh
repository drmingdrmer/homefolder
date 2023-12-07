#!/bin/sh

usage()
{
    echo "$0 bla bla"
    echo "convert all arguments to valid all-lower normalized file name"
    echo ' - replace non word char with -'
    echo ' - convert to lower case'

normalized=$(echo "$*" | awk '{
    gsub(/[^a-zA-Z0-9]/, "-", $0);
    gsub(/--*/, "-", $0);
    print tolower($0);
}')

echo "$normalized"
printf "%s" "$normalized" | set-clipboard
