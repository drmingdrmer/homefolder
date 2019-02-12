#!/bin/sh

cmd=${1-force_update}

echo "cmd: ($cmd)"

(
cd src
fns=$(ls git-* p8ln)

echo build files: $fns

for f in $fns; do
    cat $f | awk -v excludeline="^#" -f preproc.awk > ../bin/$f && chmod +x ../bin/$f
done

for f in $fns; do
    test ! -d "../gist/$f" || cp ../bin/$f ../gist/$f/$f
    test ! -d "../repo/$f" || cp ../bin/$f ../repo/$f/$f
done

) || exit 1


if [ "$cmd" == "build" ]; then
    exit 0
fi


dd()
{
    Green="$(                   tput setaf 2)"
    NC="$(                      tput sgr0)" # No Color
    echo "$Green$@$NC"
}

die()
{
    echo "$@" >&2
    exit 1
}

force_update()
{
    local dir="$1"
    local url="$2"
    local branch=master

    if [ ! -d "$dir" ]; then
        dd "not found: $dir"
        dd "clone $dir from $url"
        git clone "$url" "$dir"
    fi

    dd "force_update $dir $url"
    cd "$dir"

    # manually make a tree object
    git add -u || die add -u
    tree=$(git write-tree) || die git-write-tree

    git checkout $branch -f || die checkout $branch
    git reset --hard origin/$branch || die reset --hard to origin/$branch

    # use content in "$tree" to create a commit
    git read-tree "$tree" || die git-read-tree
    if git diff --cached --name-only --relative HEAD -- | grep -qs .; then
        git status --untracked-files=no
        git commit -m 'auto commit' || die git-commit
        git log --color --decorate --abbrev-commit --find-renames --format=oneline -3 --stat
    else
        dd nothing changed
    fi

    git push origin $branch
    git reset --hard
}


while read name dir url; do
    echo === $dir : $cmd ===
    case $cmd in
        push)
            ( cd $dir && git push origin master; )
            ;;
        fetch)
            ( cd $dir && git fetch origin; )
            ;;
        pull)
            ( cd $dir && git pull --ff-only origin; )
            ;;
        status)
            ( cd $dir && git status; )
            ;;
        commit)
            (
            cd $dir && git add -u || exit 1
            { git diff-index --name-only HEAD -- | grep -qs .; } && git commit -m 'auto commit' || exit 0
                )
            ;;
        force_update)
            (
            force_update "$dir" "$url"
            )
            ;;
        *)
            ( cd $dir && git "$@"; )
            ;;
    esac

done <<-END
git-box          gist/git-box           git@gist.github.com:07faee6c4f7c8e31da3c5210cfa04034.git
git-gotofix      gist/git-gotofix       git@gist.github.com:241dd1b3655f04190b0c6d06aa1dd258.git
git-split        gist/git-split         git@gist.github.com:aadec82ccc43c25b9a1a40fcaa96f7e9.git
git-subrepo      gist/git-subrepo       git@gist.github.com:ff72ee00df7b7a359263fc3b15d093b0.git
p8ln             gist/p8ln              git@gist.github.com:8dd50b66aca51595e71dc247dcb559c1.git
git-subrepo      repo/git-subrepo       git@github.com:baishancloud/git-subrepo.git
git-upstream     repo/git-upstream      git@github.com:baishancloud/git-upstream.git
END
