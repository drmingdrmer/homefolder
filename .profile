if [ "x$__XP_PROFILE__" != "x" ]; then
    return
fi
__XP_PROFILE__=1

XPBASE=$HOME/xp/bash-d

export XPBASE

. $XPBASE/inc/util.sh
env_init_path

if [ "$BASH" ]; then
    for rcfn in ~/.bashrc;do
        if [ -f $rcfn ]; then
            . $rcfn
        fi
    done
fi


[ -t 1 ] && mesg y

# vim: ft=sh

##
# Your previous /Users/drmingdrmer/.profile file was backed up as /Users/drmingdrmer/.profile.macports-saved_2012-09-23_at_22:32:56
##

# MacPorts Installer addition on 2012-09-23_at_22:32:56: adding an appropriate PATH variable for use with MacPorts.
export PATH=/usr/local/opt/ipython@5/bin:/opt/local/bin:/opt/local/sbin:$PATH
# Finished adapting your PATH environment variable for use with MacPorts.

