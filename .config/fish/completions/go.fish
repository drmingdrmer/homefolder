
function __complete_go
    set -lx COMP_LINE (commandline -cp)
    test -z (commandline -ct)
    and set COMP_LINE "$COMP_LINE "
    /Users/drdrxp/xp/vcs/go/bin/gocomplete
end
complete -f -c go -a "(__complete_go)"

