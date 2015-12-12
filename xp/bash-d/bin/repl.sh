#!/bin/sh
if [ $# -ne 3 ]; then
  echo "Usage: replace original target filepattern"
  exit
fi

Pattern=$1
Repl=$2
FilePtn=$3


Files=`find . -type f -name "$FilePtn" ! -name '.*' ! -path '*/.git/*' ! -path '*/.svn/*' ! -path '*/.hg/*'`


for filename in $Files
do
  sed -i "s/\b$1\b/$2/g" "$filename"
  # replace $1 $2 -- $filename
  # mv TMP $filename
done
