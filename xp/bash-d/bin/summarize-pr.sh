#!/bin/sh


usage()
{
    echo "Create a comment that summarizes the changes of a pull-request"
    echo "Usage:"
    echo "    # run in a github repo working tree"
    echo "    $0 <pr-number>"
    echo "Dependency:"
    echo "    gh # github CLI"
    echo "    pip install poe-api"
    echo "    # Poe token, see: https://github.com/ading2210/poe-api#finding-your-token"
}

example_summarize_all_open_pr()
{
    # https://docs.github.com/en/search-github/searching-on-github/searching-issues-and-pull-requests#search-for-draft-pull-requests
    gh pr list --search "draft:false" | while read a b; do
        echo $a;
        summarize-pr.sh $a;
    done
}

set -o errexit

pr=$1

prompt="$(
echo 'write git commit message for the following patch in detail:';
echo '```diff';
gh pr diff $1;
echo '```';
)"

summary="$(echo "$prompt" | call-poe.py "$XP_SEC_POE_TOKEN")"

echo "Summary of PR $pr"
echo "$summary"
echo ""

gh pr comment $pr --body "
### PR summary(by Claude):

$summary"
