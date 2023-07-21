#!/bin/sh

echo "Enter text to rephrase, followed by ^D"
src="$(</dev/stdin)"


prompt="$(
echo 'rephrase the following markdown:'
echo '---'
echo "$src"
)"


echo "$prompt" | non-interactive-gpt4-poe.sh
