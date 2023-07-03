#!/bin/sh

echo "Enter text to rephrase, followed with ^D"
x="$(</dev/stdin)"
# read -d '' x <<EOF


prompt="$(
echo 'rephrase:'
echo '```'
echo "$x"
echo '```'
)"


summary="$(echo "$prompt" | call-poe.py "$XP_SEC_POE_TOKEN")"

echo "$summary" | set-clipboard

echo "--------- output(has been stored in clipboard) ---------"
echo "$summary"
echo ""

