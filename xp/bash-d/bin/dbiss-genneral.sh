#!/bin/sh


gh issue create \
    --title "$1"
    --body "$*" \
