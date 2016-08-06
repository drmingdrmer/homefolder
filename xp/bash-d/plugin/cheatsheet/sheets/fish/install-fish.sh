#!/bin/sh

brew install fish
curl -L https://github.com/oh-my-fish/oh-my-fish/raw/master/bin/install | fish
omf help

# theme:
# to install, omf install <name>
# https://github.com/oh-my-fish/oh-my-fish/blob/master/docs/Themes.md
#
# 设置fish为默认shell
# chsh -s /usr/local/bin/fish
#
# 在mac下的iTerm2里，你需要打开： iTerm2 > Preferences > Profiles
#
# 在Command里写入/usr/local/bin/fish
#
# 与tmux整合
# 在~/.tmux.conf里加上：
#
# set -g default-command /usr/local/bin/fish
