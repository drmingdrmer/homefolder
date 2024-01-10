#!/bin/sh

usage()
{
    echo "$0 bla bla"
    echo "convert all arguments to valid all-lower normalized file name"
    echo ' - replace non word char with -'
    echo ' - convert to lower case'
}

# join lines:
# awk '{printf "%s ", $0}'
normalized=$(echo "$*" | awk '{printf "%s ", $0}' | awk '{
    gsub(/[^a-zA-Z0-9]/, "-", $0);
    gsub(/--*/, "-", $0);
    gsub(/^--*/, "", $0);
    gsub(/--*$/, "", $0);
    print tolower($0);
}')

echo "$normalized"
printf "%s" "$normalized" | set-clipboard
