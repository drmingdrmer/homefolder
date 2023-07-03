#!/bin/sh

echo "Enter prompt, followed by ^D"
prompt="$(</dev/stdin)"


output="$(echo "$prompt" | call-poe.py -b gpt4  "$XP_SEC_POE_TOKEN")"

echo "$output" | set-clipboard

echo "--------- output(has been stored in clipboard) ---------"
echo "$output"
echo ""

