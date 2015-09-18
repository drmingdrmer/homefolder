#!/bin/sh

cd
rsync -Rauvz --delete 64.120.143.218::rs/bash.xp .
cd bash.xp
./inst
sudo -s

cd ~/tmp
wget ftp://ftp.vim.org/pub/vim/unix/vim-7.3.tar.bz2
tar -xjf vim-7.3.tar.bz2
cd vim73/
./configure --prefix=$HOME   --with-features=huge
make install

