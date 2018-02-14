#!/bin/sh


(
cd src
fns=$(ls git-* p8ln)

echo build files: $fns

for f in $fns; do
    cat $f | awk -f preproc.awk > ../bin/$f && chmod +x ../bin/$f
done

for f in $fns; do
    test ! -d "../gist/$f" || cp ../bin/$f ../gist/$f/$f
    test ! -d "../repo/$f" || cp ../bin/$f ../repo/$f/$f
done

) || exit 1

(
cd repo \
    && ./ctl commit \
    && ./ctl fetch \
    && ./ctl rebase origin/master \
    && ./ctl push
) || exit 1
 
(
cd gist \
    && ./gist-ctrl commit \
    && ./gist-ctrl fetch \
    && ./gist-ctrl rebase origin/master \
    && ./gist-ctrl push
) || exit 1

