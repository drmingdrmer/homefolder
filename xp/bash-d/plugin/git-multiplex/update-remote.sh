#!/bin/sh

cmd=${1:force_update}

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


if [ "$cmd" == "build" ]; then
    exit 0
fi


force_update()
{
    local dir="$1"
    local url="$2"
    local branch=master

    if [ ! -d "$dir" ]; then
        echo "not found: $dir"
        echo "clone $dir from $url"
        git clone "$url" "$dir"
    fi

    cd "$dir"

    # manually make a tree object
    git add -u || exit 1
    tree=$(git write-tree) || exit 1

    git checkout $branch origin/$branch -f || exit 1
    git reset --hard origin/$branch || exit 1

    # use content in "$tree" to create a commit
    git read-tree "$tree" || exit 1
    git status --untracked-files=no
    git commit -m 'auto commit' || exit 1
    git log --color --decorate --abbrev-commit --find-renames --format=oneline -3 --stat

    git push origin $branch
}


while read name dir url; do
    echo === $dir : $cmd ===
    if [ -d "$name" ]; then
        case $cmd in
            push)
                ( cd $name && git push origin master; )
                ;;
            fetch)
                ( cd $name && git fetch origin; )
                ;;
            pull)
                ( cd $name && git pull --ff-only origin; )
                ;;
            status)
                ( cd $name && git status; )
                ;;
            commit)
                (
                cd $name && git add -u || exit 1
                { git diff-index --name-only HEAD -- | grep -qs .; } && git commit -m 'auto commit' || exit 0
                    )
                ;;
            force_update)
                (
                force_update "$dir" "$url"
                )
                ;;
            *)
                ( cd $name && git "$@"; )
                ;;

        esac
    fi
done <<-END
git-box          gist/git-box           git@gist.github.com:07faee6c4f7c8e31da3c5210cfa04034.git
git-gotofix      gist/git-gotofix       git@gist.github.com:241dd1b3655f04190b0c6d06aa1dd258.git
git-subrepo      gist/git-subrepo       git@gist.github.com:ff72ee00df7b7a359263fc3b15d093b0.git
p8ln             gist/p8ln              git@gist.github.com:8dd50b66aca51595e71dc247dcb559c1.git
git-subrepo      repo/git-subrepo       git@github.com:baishancloud/git-subrepo.git
git-upstream     repo/git-upstream      git@github.com:baishancloud/git-upstream.git
END
