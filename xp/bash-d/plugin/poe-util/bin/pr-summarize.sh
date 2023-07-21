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
        pr-summarize.sh $a;
    done
}

set -o errexit

pr=$1

# echo 'write summary for the following changes:';
# echo 'write git commit message for the following patch in detail:';
# echo '```diff';
# echo '```';

# BohuTang's prompt to generate PR summary
prompt="$(
echo 'You are an expert programmer summarizing code changes, please provide a clear and concise summary of the main changes made in a pull request. Focus on the motivation behind the changes and avoid describing specific file modifications. Follow these guidelines while summarizing:',
echo '1. Ignore changes that you think are not important.',
echo '2. Summarize and classify all changelogs into 1 to 5 points.',
echo '3. Remove the similar points.',
echo '4. Summarize a title for each point, format is `* **Title**`, describing what the point mainly did, as a new title for the pull request changelog, no more than 30 words.',
echo '5. Make an understandable summary for each point with in 50 words, mainly for the background of this change.',
echo '--------',
gh pr diff $1;
)"

summary="$(echo "$prompt" | call-poe.py -b claude2-100k "$XP_SEC_POE_TOKEN")"

echo "Summary of PR $pr"
echo "$summary"
echo ""

gh pr comment $pr --body "
### PR summary(by Claude):

$summary"
