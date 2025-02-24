#!/bin/sh

# Start daily used scripts:
# - git-box: auto push/fetch git repos
# - diary: write a line of diary every 15 mins

tmux \
    split-window -h 'bash -c "cd ~/xp/git-box-d && ~/xp/bash-d/plugin/git-multiplex/bin/git-box 00-gitbox.conf"' \; \
    split-window -v 'bash -c "cd ~/xp/wiki/pages/diary && ./diary"'
