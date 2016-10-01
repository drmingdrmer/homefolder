#!/bin/sh

git config --global alias.stsh      'stash --keep-index'           git stsh      # stash only unstaged changes to tracked files
                          stash                                    git stash     # stash any changes to tracked files
git config --global alias.staash    'stash --include-untracked'    git staash    # stash untracked and tracked files
git config --global alias.staaash   'stash --all'                  git staaash   # stash ignored, untracked, and tracked files
