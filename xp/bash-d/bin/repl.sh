#!/bin/sh
if [ $# -ne 3 ]; then
    echo "Usage: replace original target filepattern"
    exit
fi

Pattern=$1
Repl=$2
FilePtn=$3


files=`find . -type f -name "$FilePtn" ! -name '.*' ! -path '*/.git/*' ! -path '*/.svn/*' ! -path '*/.hg/*'`


for filename in $files
do
    echo replacing $filename

    if test "$(uname -s)" = "Darwin"
    then
        sed -i '' 's/[[:<:]]'"$Pattern"'[[:>:]]/'"$Repl"'/g' "$filename"
    else
        sed -i 's/\b'"$Pattern"'\b/'"$Repl"'/g' "$filename"
    fi
done
