#!/bin/sh

# Create pr from CLI
# Deps:
# brew install gh

upstream='ups/main'

branch=$(git symbolic-ref --short HEAD)
title="$(git log -n1 --format='%s')"
body="$(git log $upstream..HEAD --format='##### %s%+b%n')"

c_feat=''
c_fix=''
c_doc=''
c_refine=''
c_test=''

if git log $upstream..HEAD --format='%s' | grep 'feature:'; then
    c_feat="- New Feature"
fi
if git log $upstream..HEAD --format='%s' | grep 'fix:'; then
    c_fix="- Bug Fix"
fi
if git log $upstream..HEAD --format='%s' | grep 'doc:'; then
    c_doc="- Documentation"
fi
if git log $upstream..HEAD --format='%s' | grep 'refine:\|refactor:\|test:'; then
    c_refine="- Improvement"
fi
if git log $upstream..HEAD --format='%s' | grep 'ci:\|test:'; then
    c_test="- Build/Testing/CI"
fi

body="$(
cat <<-END

I hereby agree to the terms of the CLA available at: https://databend.rs/policies/cla/

## Summary

$body

## Changelog

$c_feat
$c_fix
$c_doc
$c_refine
$c_test

## Related Issues

END
)"


# - New Feature
# - Bug Fix
# - Improvement
# - Performance Improvement
# - Build/Testing/CI
# - Documentation
# - Website
# - Other

echo "$title"
echo "$body"

read -p "Continue? [y/n]" a
if [ ".$a" == ".y" ]; then
    :
else
    echo "Exit"
    exit 0
fi

git push origin $branch || exit 1

gh pr create \
    --draft \
    --base main \
    --head drmingdrmer:$branch \
    --title "$title" \
    --body "$body"

