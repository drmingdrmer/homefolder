#!/bin/sh

usage()
{
    echo "echo <text> | $0 <instructions>"
}

echo "Enter text to process, followed by ^D"
instruction="$@"
src="$(</dev/stdin)"


{
    echo "$instruction:"
    echo '---'
    echo "$src"
} | non-interactive-gpt4-poe.sh
