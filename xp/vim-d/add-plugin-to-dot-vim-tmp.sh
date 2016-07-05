#!/bin/sh

cd dot-vim-tmp/ \
    && { git init || ``; } \
    && git remote add ctrlp git@github.com:ctrlpvim/ctrlp.vim.git \
    && git fetch --all


