#!/bin/sh

cwd=$(pwd)
testdir="$cwd/t"

# trap 'cd "$cwd"; rm -rf "$testdir"' 0

die()
{
    echo "$@" >&2
    exit 1
}

_gl()
{
    git log --no-color \
        --graph \
        --decorate \
        --pretty=oneline \
        --abbrev-commit \
        -M \
        --all
}

compare_file()
{
    local expected=$1
    local actual=$2
    shift
    shift

    diff --ignore-all-space "$expected" "$actual" \
        || die failure comparing: "$@"
}

test_case()
{
    local name=$1

    rm -rf "$testdir" 2>/dev/null

    mkdir -p "$testdir" \
        && cd "$testdir" \
        && {
            test -r "$cwd/case/$name/repo.tgz" \
                && tar -xzf "$cwd/case/$name/repo.tgz" -C "$testdir/" \
                || tar -xzf "$cwd/repo.tgz" -C "$testdir/"
        } \
        && cd "$testdir/repo" \
        && _gl >"$testdir/init" \
        && {
            test -r "$cwd/case/$name/init" \
                && compare_file "$cwd/case/$name/init" "$testdir/init" init of $name \
                || compare_file "$cwd/init"            "$testdir/init" init of $name
        } \
        && cmd=$(cat $cwd/case/$name/cmd) \
        && $cmd \
        && _gl >"$testdir/rst" \
        && compare_file "$cwd/case/$name/rst" "$testdir/rst" rst of $name \
        && echo ok $name
}

for c in $(cd case && ls)
do
    test_case $c
done
