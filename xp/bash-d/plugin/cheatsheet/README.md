# cheatsheet

A simple cheatsheet looking up script and several sheets.

# Status

This library is a harmless experimental project.

# Description

I wrote this script when I found I have too many trivial things to remember.
Like how to revert a git commit, what is the printf format in c.

Yes I can find it in a minute on google. But I want to be able to find it in
seconds.

A simple shell command `cheat c print` gives me everything I need.

# Install

```shell
cd ~
git clone https://github.com/drmingdrmer/cheatsheet.git

mkdir -p ~/bin
ln -s ~/cheatsheet/bin/cheat .

# And make sure ~/bin is in your $PATH env.
# Usually by adding a line "export PATH=$PATH:$HOME/bin" to your ~/.bashrc
```

# Usage

## Add sheets

Cheatsheets are kept in folder `sheets`.
Folder name is the topic name.
A Sheet under a topic is a plain text file.

```
▾ sheets/
  ▾ automake/
      link-vars
  ▾ awk/
      load-external-file
      split-txt-every-15-lines-with-awk
  ▸ bash/
  ...
```

Just put your own topic or sheet here and it can be found and searched.


## Cheat

```shell
cheat <topic> [<optional sheet name pattern>]

# example:
# > cheat git bran
# It shows all sheets under topic "git" that matches "bran":
#
# --- ./git/get-branch-default-remote ---
# git config --get branch.$branchname.remote
#
#
# --- ./git/get-branch-name ---
# # echo "master"
# git symbolic-ref --short HEAD
#
# # echo "refs/heads/master"
# git rev-parse --symbolic-full-name HEAD
#
#
# --- ./git/list-merged-or-not-merged-branch ---
# git branch --merged master

```


## My sheets lib

The tips in here I collected is something I always forget.
`cheat` saved me a lot time, and these tips might save your time, too.


# Author

Zhang Yanpo (张炎泼) <drdr.xp@gmail.com>

# Copyright and License

The MIT License (MIT)

Copyright (c) 2015 Zhang Yanpo (张炎泼) <drdr.xp@gmail.com>
