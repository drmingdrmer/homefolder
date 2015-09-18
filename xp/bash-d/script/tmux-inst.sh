#!/bin/sh

which tmux && exit 0

cd ~

mkdir -p tmp-tmux
cd tmp-tmux

fn=tmux-1.8.tar.gz
wget -O $fn "http://garr.dl.sourceforge.net/project/tmux/tmux/tmux-1.8/$fn"

tar -xzf $fn

cd tmux-1.8 \
    && ./configure && sudo make install

rm -rf tmp-tmux
