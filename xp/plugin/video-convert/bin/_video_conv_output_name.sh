#!/bin/sh

default_output_dir="$1"
input="$2"

if [ -z "$3" ]; then
    output="${default_output_dir}/${input##*/}"
    mkdir -p "${default_output_dir}"
elif [ ".${3: -1}" = "./" ]; then
    # If output ends with '/', append the original name
    output="${3}${input##*/}"
    mkdir -p "${3}"
else
    output="${3}"
fi

echo "$output"
exit
