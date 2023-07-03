#!/bin/sh

echo "Enter text to rephrase, followed with ^D"
src="$(</dev/stdin)"


prompt="$(
echo 'rephrase:'
echo '```'
echo "$src"
echo '```'
)"


summary="$(echo "$prompt" | call-poe.py "$XP_SEC_POE_TOKEN")"

echo "$summary" | set-clipboard

echo "--------- output(has been stored in clipboard) ---------"
echo "$summary"
echo ""

