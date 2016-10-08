#!/bin/bash

ver=7.4
folder=vim74
fn=vim-$ver.tar.bz2
url=ftp://ftp.vim.org/pub/vim/unix/$fn

{ vim --version | head -n1 | grep $ver; } && exit 0

cd ~

mkdir tmp-vim
cd tmp-vim

wget $url
tar -xjf $fn

cd $folder

./configure                \
  --prefix=$HOME          \
  # --enable-perlinterp        \
  # --enable-pythoninterp      \
  # --enable-tclinterp         \
  # --enable-rubyinterp        \
  --enable-cscope            \
  --enable-multibyte         \
  --enable-motif-check    \
  --enable-athena-check   \
  --enable-nextaw-check   \
  --enable-carbon-check   \
  --with-features=huge

make install

cd ~
rm -rf tmp-vim
