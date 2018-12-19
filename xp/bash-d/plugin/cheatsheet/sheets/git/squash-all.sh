#!/bin/sh

hash=$(echo "squash-all" | git commit-tree HEAD^{tree})

git reset --hard $hash
