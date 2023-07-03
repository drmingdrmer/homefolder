#!/bin/sh

echo "Enter text to rephrase, followed with ^D"
src="$(</dev/stdin)"


prompt="$(
echo 'rephrase the following markdown:'
echo '---'
echo "$src"
)"


summary="$(echo "$prompt" | call-poe.py -b gpt4  "$XP_SEC_POE_TOKEN")"

echo "$summary" | set-clipboard

echo "--------- output(has been stored in clipboard) ---------"
echo "$summary"
echo ""

