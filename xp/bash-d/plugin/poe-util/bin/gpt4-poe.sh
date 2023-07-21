#!/bin/sh

echo "Enter prompt, followed by ^D"
prompt="$(</dev/stdin)"

echo "$prompt" | non-interactive-gpt4-poe.sh
