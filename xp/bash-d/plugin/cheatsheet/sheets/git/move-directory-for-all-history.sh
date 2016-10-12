#!/bin/sh

git filter-branch -f --tree-filter 'mv src/s2/* src/' HEAD
git filter-branch -f --tree-filter 'mv src/s2/* src/ || ``' HEAD
