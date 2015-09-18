#!/bin/sh

tmp=~/xptmp

inst_vim()
{
    cd $tmp
    wget sandbox.sinastorage.com/xp/vim-7.3.tar.bz2 -O vim-7.3.tar.bz2
    tar -xjf vim-7.3.tar.bz2
    cd vim73/
    ./configure --prefix=$HOME   --with-features=huge
    make install
    cd ~ && rm -rf $tmp;
}


inst_git()
{
    local gitDownloadUrl="http://s2.sinastorage.com/pkg/git-v1.7.6.1.tgz"
    local ofile=${gitDownloadUrl##*/}

    if [ ! -x /usr/local/bin/git ]; then
        cd ~ \
            && mkdir -p $tmp \
            && wget "$gitDownloadUrl" -O $ofile \
            && tar -xzf $ofile \
            && cd git-v1.7.6.1 \
            && make prefix=/usr/local install install-doc install-html install-info;

        cd ~ && rm -rf $tmp;
    fi
}

inst_git
inst_vim
sh ./btsync-inst.sh
