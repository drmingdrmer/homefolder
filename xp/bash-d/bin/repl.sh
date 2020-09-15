#!/bin/sh
if [ $# -ne 3 ]; then
    echo "Usage: repl.sh original target filepattern"
    exit
fi

Pattern=$1
Repl=$2
FilePtn=$3

files=$(find . -type f -name "$FilePtn" ! -name '.*' ! -path '*/.git/*' ! -path '*/.svn/*' ! -path '*/.hg/*')

git_dir=$(git rev-parse --show-toplevel)

for filename in $files
do

    if [ ".$git_dir" != "." ]; then
        if git check-ignore -q "$filename"; then
            # echo 'ignored:' "$filename"
            continue
        fi
    fi

    echo 'replacing:' "$filename"
    continue

    if test "$(uname -s)" = "Darwin"
    then
        sed -i '' 's/[[:<:]]'"$Pattern"'[[:>:]]/'"$Repl"'/g' "$filename"
    else
        sed -i 's/\b'"$Pattern"'\b/'"$Repl"'/g' "$filename"
    fi
done
