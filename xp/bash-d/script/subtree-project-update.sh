#!/bin/sh

cd $(git rev-parse --show-toplevel)

while read path branch remote; do

    git subtree split -P "$path" --branch "$branch" --rejoin
    git push "$remote" $branch:master

done <<-END
xp/bash-d/plugin/cheatsheet         cheatsheet         git@github.com:drmingdrmer/cheatsheet.git
xp/vim-d/my/vim-align-char          vim-align-char     git@github.com:drmingdrmer/vim-align-char.git
END
