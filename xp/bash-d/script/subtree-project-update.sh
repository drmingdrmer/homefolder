#!/bin/sh

cd $(git rev-parse --show-toplevel)

git subtree split -P xp/bash-d/plugin/cheatsheet --branch cheatsheet --rejoin

git remote add cs git@github.com:drmingdrmer/cheatsheet.git

git push cs cheatsheet:master

git remote remove cs
