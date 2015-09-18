#!/bin/sh


# TODO fetch remote and leave message if there is update


XAct="rsync to my vps"
cd -P $XpBase/.. \
    && . $XpBase/script/rsync.to.my.vps \
    && xok || xerr
cd -

# # Note: __tmp__ is the temporary directory used by ex.svn
# XAct=plugins.extern.git.export
# for i in `ls -d bash.xp/vim.xp/plugins.extern/*.git`;do

#   echo to export git "-$i-"

#   # copy to temporary svn export directory
#   mkdir -p "__tmp__/$i"
#   cp -R $i/* "__tmp__/$i"
#   rm -rf "__tmp__/$i/.git"

# done


# # Note: __tmp__ is the temporary directory used by ex.svn
# XAct=plugins.extern.svn.export
# for i in `ls -d bash.xp/vim.xp/plugins.extern/*.svn`;do

#   echo to export svn "-$i-"

#   mkdir -p "__tmp__/$i"
#   svn export --force "$i" "__tmp__/$i"
# done


# XAct=bash.xp.export
# $XpBase/sbin/ex.svn bash.xp/ -x "chronograph vim.xp/addins.v?"\
#     && xok "`ls -lh ~/bash.xp.tgz.txt`" \
#     || xerr

# rm ~/bash.xp.tgz
# rm -rf ~/__tmp__

