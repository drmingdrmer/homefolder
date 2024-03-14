#!/bin/sh

# Create pr from CLI
# Deps:
# brew install gh

usage()
{
    cat <<-END
    $0 [-l <label>]
END

}

map_label()
{
    case $1 in
        meta)
            echo 'A-databend-meta'
            ;;
        *)
            echo "$1"
            ;;

    esac
}


labels=""
case $1 in
    -l)
        shift
        lb="$(map_label "$1")"
        labels="--label $lb"
        shift
    ;;

esac

upstream='ups/main'

branch=$(git symbolic-ref --short HEAD)
title="$(git log -n1 --format='%s')"
body="$(git log $upstream..HEAD --format='##### %s%n%+b%n')"

c_feat=''
c_fix=''
c_doc=''
c_refine=''
c_test=''

# Not included:
# - [x] Breaking Change (fix or feature that could cause existing functionality not to work as expected)
# - [x] Performance Improvement


if git log $upstream..HEAD --format='%s' | grep 'feature:\|feat:'; then
    c_feat="- [x] New Feature (non-breaking change which adds functionality)"
fi
if git log $upstream..HEAD --format='%s' | grep 'fix:'; then
    c_fix="- [x] Bug Fix (non-breaking change which fixes an issue)"
fi
if git log $upstream..HEAD --format='%s' | grep 'doc:'; then
    c_doc="- [x] Documentation Update"
fi
if git log $upstream..HEAD --format='%s' | grep 'refine:\|refactor:\|test:'; then
    c_refine="- [x] Refactoring"
fi
if git log $upstream..HEAD --format='%s' | grep 'ci:\|test:'; then
    c_test="- [x] Other"
fi

body="$(
cat <<-END


I hereby agree to the terms of the CLA available at: https://docs.databend.com/dev/policies/cla/

## Summary

$body

## Tests

- [x] Unit Test
- [ ] Logic Test
- [ ] Benchmark Test
- [ ] No Test  - _Explain why_

## Type of change

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
    $labels \
    --title "$title" \
    --body "$body"

