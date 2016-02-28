#!/bin/sh

cwd=
testdir=

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

_gl_tree()
{
    git log --no-color \
        --graph \
        --decorate \
        --pretty=oneline \
        --abbrev-commit \
        -M \
        --format="%t %s" \
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
    local casedir="$cwd/case/$name"

    rm -rf "$testdir" 2>/dev/null

    mkdir -p "$testdir" \
        && cd "$testdir" \
        && {
            test -r "$casedir/repo.tgz" \
                && tar -xzf "$casedir/repo.tgz" -C "$testdir/" \
                || tar -xzf "$cwd/repo.tgz" -C "$testdir/"
        } \
        && cd "$testdir/repo" \
        && _gl >"$testdir/init" \
        && {
            test -r "$casedir/init" \
                && compare_file "$casedir/init" "$testdir/init" init of $name \
                || compare_file "$cwd/init"            "$testdir/init" init of $name
        } \
        && cmd=$(cat $casedir/cmd) \
        && {
            $cmd || test -r "$casedir/failure" || die failure $name: "$cmd"
        } \
        && _gl >"$testdir/rst" \
        && _gl_tree >"$testdir/tree-rst" \
        && {
            if test -r "$casedir/rst"
            then
                compare_file "$casedir/rst" "$testdir/rst" rst of $name
            fi
            if test -r "$casedir/tree-rst"
            then
                compare_file "$casedir/tree-rst" "$testdir/tree-rst" tree-rst of $name
            fi
        } \
        && echo "$(tput setaf 2)ok $name$(tput sgr0)"
}

run_test()
{
    cwd=$(pwd)
    testdir="$cwd/t"

    # trap 'cd "$cwd"; rm -rf "$testdir"' 0

    for c in $(cd case && ls)
    do
        test_case $c
    done
}

main()
{
    local testname="$1"
    if test -z "$testname"; then
        for testname in $(ls)
        do
            if test -d "$testname"
            then
                ( cd "$testname" && run_test; )
            fi
        done
    else
        shift
        ( cd "$testname" && run_test; )
    fi
}

main "$@"
