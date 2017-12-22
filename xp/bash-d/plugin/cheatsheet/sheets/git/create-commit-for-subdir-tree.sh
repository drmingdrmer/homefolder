#!/bin/sh

treehash=$(git rev-parse HEAD^{tree}:my_sub_dir)

# commit with the same message/author etc as HEAD
# without parent
git log -1 --pretty=format:'%an%n%ae%n%aD%n%cn%n%ce%n%cD%n%B' "HEAD" | (

read   GIT_AUTHOR_NAME
read   GIT_AUTHOR_EMAIL
read   GIT_AUTHOR_DATE
read   GIT_COMMITTER_NAME
read   GIT_COMMITTER_EMAIL
read   GIT_COMMITTER_DATE
export GIT_AUTHOR_NAME
export GIT_AUTHOR_EMAIL
export GIT_AUTHOR_DATE
export GIT_COMMITTER_NAME
export GIT_COMMITTER_EMAIL
export GIT_COMMITTER_DATE

cat | git commit-tree $treehash
)
