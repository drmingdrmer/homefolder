#!/bin/bash

new_branch_with_file()
{
    local name=$1
    git checkout -b "br-$name" master \
        && echo "$name" >"$name" \
        && git add "$name" \
        && git commit -m "add $name"
}

assert_git_log_message()
{
    local br=$1
    local expected="$2"
    [ ".$(git log --format="%s" -n1 $br)" = ".$expected" ] \
        || { echo "expected to be $expected branch log $br"; return 1; }
}

assert_file_content()
{
    local fn="$1"
    local cont=$(echo -e "$2")
    [ ".$(cat "$fn"| xxd)" = ".$(echo "$cont" | xxd)" ] \
        || { echo "expected '$fn' to be $(echo "$cont" | xxd) but $(cat "$fn"| xxd)"; return 1; }
}

assert_branch_nr_commit()
{
    local br=$1
    local nr=$2

    [ ".$(git log --format="%%" $br |wc -l | awk '{print $1}')" = ".$nr" ] \
        || { echo "expected to be $nr commits on $br"; return 1; }
}

assert_lines()
{
    local l1=$(echo -e "$1")
    local l2="$2"

    [ ".$(echo -n "$l1")" = ".$(echo -n "$l2")" ] \
        || { echo "expect: '$l1' but '$l2'"; return 1; }
}

assert_file_not_exist()
{
    local fn="$1"
    local mes="$2"
    if [ -f "$fn" ]; then
        echo "expect $fn not to exist $mes"
        return 1
    fi
}

assert_file_exist()
{
    local fn="$1"
    local mes="$2"
    if [ -f "$fn" ]; then
        :
    else
        echo "expect $fn to exist $mes"
        return 1
    fi
}

failit()
{
    $1 && { echo "should fail: '$1'"; return 1; }
    return 0;
}

err_stat()
{
    gl mrg
    git st
    return 1
}

t()
{
    local name="$1"
    $name || { echo "fail: $name"; return 1; }
}

test_multi_file_multi_branch()
{
    (
    rm -rf repo
    mkdir repo \
        && cd repo \
        && git init . \
        && git commit --allow-empty -m 'init' \
        && echo "-- branch 'a' has 2 files" \
        && new_branch_with_file a \
        && echo "x" > 'x -> x' \
        && git add 'x -> x' \
        && git commit -m "add 'x -> x'" \
        && echo "-- branch b, c, d has 1 file respectivly" \
        && new_branch_with_file b \
        && new_branch_with_file c \
        && new_branch_with_file d \
        && echo "-- branch mrg merges them all" \
        && git checkout -b mrg master \
        && git merge br-a --no-ff -m "merge br-a" \
        && git merge br-b --no-ff -m "merge br-b" \
        && git merge br-c --no-ff -m "merge br-c" \
        && git merge br-d --no-ff -m "merge br-d" \
        && echo "-- add changes to files" \
        && echo "A">>a \
        && echo "X">>'x -> x' \
        && echo "B">>b \
        && echo "C">>c \
        && echo "-- about to commit 3 branches out of 4" \
        && git add a 'x -> x' b c \
        && echo "D">>d \
        && git-bci -m "change axbc" \
        && assert_git_log_message br-a "change axbc" \
        && assert_git_log_message br-b "change axbc" \
        && assert_git_log_message br-c "change axbc" \
        && echo "-- test git status" \
        && [ ".$(git status -s)" = ". M d" ] \
        && echo "-- test file contents" \
        && assert_file_content a 'a\nA' \
        && assert_file_content 'x -> x' 'x\nX' \
        && assert_file_content b 'b\nB' \
        && assert_file_content c 'c\nC' \
        && assert_file_content d 'd\nD' \
        && echo "-- test branch graph" \
        && assert_branch_nr_commit master..br-a 3 \
        && assert_branch_nr_commit master..br-b 2 \
        && assert_branch_nr_commit master..br-c 2 \
        && assert_branch_nr_commit master..br-d 1 \
        && echo "---ok---" \
        || err_stat
    ) && rm -rf repo
}

test_file_in_no_branch()
{
    (
    rm -rf repo
    mkdir repo \
        && cd repo \
        && git init . \
        && git commit --allow-empty -m 'init' \
        && new_branch_with_file a \
        && new_branch_with_file b \
        && echo "-- branch mrg merges them all" \
        && git checkout -b mrg master \
        && git merge br-a --no-ff -m "merge br-a" \
        && git merge br-b --no-ff -m "merge br-b" \
        && git branch -d br-a \
        && echo "-- add changes to files" \
        && echo "A">>a \
        && echo "B">>b \
        && echo "-- about to commit 2 branches" \
        && git add a b \
        && failit 'git-bci -m "change ab"' \
        && echo "-- test git status" \
        && git status -s \
        && assert_lines '.M  a\nM  b' ".$(git status -s)" \
        && echo "-- test file contents" \
        && assert_file_content a 'a\nA' \
        && assert_file_content b 'b\nB' \
        && assert_branch_nr_commit master..mrg 4 \
        && assert_branch_nr_commit master..br-b 1 \
        && echo "---ok---" \
        || err_stat

    ) && rm -rf repo
}

test_file_in_multi_branches()
{
    (
    rm -rf repo
    mkdir repo \
        && cd repo \
        && git init . \
        && git commit --allow-empty -m 'init' \
        && new_branch_with_file a \
        && new_branch_with_file b \
        && git checkout br-a \
        && git branch br-c \
        && echo "c" > c \
        && git add c \
        && git commit -m 'a and c in c' \
        && echo "-- branch mrg merges them all" \
        && git checkout -b mrg master \
        && git merge br-a --no-ff -m "merge br-a" \
        && git merge br-b --no-ff -m "merge br-b" \
        && git merge br-c --no-ff -m "merge br-c" \
        && echo "-- add changes to files" \
        && echo "A">>a \
        && echo "B">>b \
        && echo "-- about to commit 2 branches" \
        && git add a b \
        && failit 'git-bci -m "change ab"' \
        && echo "-- test git status" \
        && assert_lines '.M  a\nM  b' ".$(git status -s)" \
        && echo "-- test file contents" \
        && assert_file_content a 'a\nA' \
        && assert_file_content b 'b\nB' \
        && echo "-- test branch commits" \
        && assert_branch_nr_commit master..mrg 5 \
        && assert_branch_nr_commit master..br-a 2 \
        && assert_branch_nr_commit master..br-b 1 \
        && assert_branch_nr_commit master..br-c 1 \
        && echo "---ok---" \
        || err_stat

    ) && rm -rf repo
}

test_specifying_branch()
{
    (
    rm -rf repo
    mkdir repo \
        && cd repo \
        && git init . \
        && git commit --allow-empty -m 'init' \
        && new_branch_with_file a \
        && new_branch_with_file b \
        && git checkout br-a \
        && git branch br-c \
        && echo "c" > c \
        && git add c \
        && git commit -m 'a and c in c' \
        && echo "-- branch mrg merges them all" \
        && git checkout -b mrg master \
        && git merge br-a --no-ff -m "merge br-a" \
        && git merge br-b --no-ff -m "merge br-b" \
        && git merge br-c --no-ff -m "merge br-c" \
        && echo "-- add changes to files" \
        && echo "A">>a \
        && echo "B">>b \
        && echo "-- about to commit 1 branches" \
        && git add a \
        && git-bci -m "change ab" -b br-a \
        && echo "-- test file contents" \
        && assert_file_content a 'a\nA' \
        && assert_file_content b 'b\nB' \
        && echo "-- test branch commits" \
        && assert_branch_nr_commit master..mrg 7 \
        && assert_branch_nr_commit master..br-a 3 \
        && assert_branch_nr_commit master..br-b 1 \
        && assert_branch_nr_commit master..br-c 1 \
        && echo "---ok---" \
        || err_stat

    ) && rm -rf repo
}

test_rename_2_files()
{
    (
    rm -rf repo
    mkdir repo \
        && cd repo \
        && git init . \
        && git commit --allow-empty -m 'init' \
        && new_branch_with_file a \
        && new_branch_with_file b \
        && new_branch_with_file c \
        && echo "-- branch mrg merges them all" \
        && git checkout -b mrg master \
        && git merge br-a --no-ff -m "merge br-a" \
        && git merge br-b --no-ff -m "merge br-b" \
        && git merge br-c --no-ff -m "merge br-c" \
        && echo "-- rename a to a2" \
        && git mv a a2 \
        && echo "-- rename b to b2" \
        && git mv b b2 \
        && git-bci -m "rename a to a2, b to b2" \
        && echo "-- test exist" \
        && assert_file_not_exist "a" \
        && assert_file_exist "a2" \
        && assert_file_not_exist "b" \
        && assert_file_exist "b2" \
        && echo "-- test file contents" \
        && assert_file_content a2 'a' \
        && assert_file_content b2 'b' \
        && echo "-- test branch commits" \
        && assert_branch_nr_commit master..mrg 10 \
        && assert_branch_nr_commit master..br-a 2 \
        && assert_branch_nr_commit master..br-b 2 \
        && assert_branch_nr_commit master..br-c 1 \
        && echo "---ok---" \
        || err_stat

    ) && rm -rf repo
}

# TODO test unicode
# TODO test rename folder

`` \
    && t test_multi_file_multi_branch \
    && t test_file_in_no_branch \
    && t test_file_in_multi_branches \
    && t test_specifying_branch \
    && t test_rename_2_files \
    && echo all tests passed
