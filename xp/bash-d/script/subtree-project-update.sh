#!/bin/sh

cd $(git rev-parse --show-toplevel)

git subtree split -P xp/bash-d/plugin/cheatsheet --branch cheatsheet --rejoin

git push git@github.com:drmingdrmer/cheatsheet.git cheatsheet:master
