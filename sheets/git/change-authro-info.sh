#!/bin/sh


old_email="$1"
new_name="$2"
new_email="$3"

git filter-branch -f --env-filter '
OLD_EMAIL="'"$old_email"'"
CORRECT_NAME="'"$new_name"'"
CORRECT_EMAIL="'"$new_email"'"
if [ "$GIT_COMMITTER_EMAIL" = "$OLD_EMAIL" ]
then
    export GIT_COMMITTER_NAME="$CORRECT_NAME"
    export GIT_COMMITTER_EMAIL="$CORRECT_EMAIL"
fi
if [ "$does_change_author" = "1" ] && [ "$GIT_AUTHOR_EMAIL" = "$OLD_EMAIL" ]
then
    export GIT_AUTHOR_NAME="$CORRECT_NAME"
    export GIT_AUTHOR_EMAIL="$CORRECT_EMAIL"
fi
' --tag-name-filter cat -- --branches --tags


exit

# then:
git push --force --tags origin 'refs/heads/*'

# config name and email
git config --local --replace-all user.name  张炎泼
git config --local --replace-all user.email xp@baishancloud.com
