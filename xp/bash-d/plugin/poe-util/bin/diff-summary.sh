#!/bin/sh


usage()
{
    echo "Summarizes diff between <base> and current work tree"
    echo "Usage:"
    echo "    # run in a github repo working tree"
    echo "    $0 <base>"
    echo "Dependency:"
    echo "    pip install poe-api"
    echo "    # Poe token, see: https://github.com/ading2210/poe-api#finding-your-token"
}

set -o errexit


base=${1-HEAD}

echo "$base"

git_dir=$(git rev-parse --git-dir)
# root="$(git rev-parse --show-toplevel)"


# BohuTang's prompt to generate PR summary
prompt="$(
echo 'You are an expert programmer summarizing code changes, please provide a clear and concise summary of the main changes made in a pull request. Focus on the motivation behind the changes and avoid describing specific file modifications. Follow these guidelines while summarizing:',
echo '1. Ignore changes that you think are not important.',
echo '2. Summarize and classify all changelogs into 1 to 5 points.',
echo '3. Remove the similar points.',
echo '4. Summarize a title for each point, format is `* **Title**`, describing what the point mainly did, as a new title for the pull request changelog, no more than 30 words.',
echo '5. Make an understandable summary for each point with in 50 words, mainly for the background of this change.',
echo '--------',
git diff --no-ext-diff $base
)"

summary="$(echo "$prompt" | call-poe.py "$XP_SEC_POE_TOKEN")"

{
    echo "$summary"
    echo ""
} > "$git_dir/xp-diff-summary"

echo "=== Diff summary between $base and current working tree ==="
cat "$git_dir/xp-diff-summary"
