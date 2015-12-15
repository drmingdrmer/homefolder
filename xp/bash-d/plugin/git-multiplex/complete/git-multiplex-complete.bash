# completion extension to git-completion.bash

_git_auto_squash() { __git_complete_revlist ; }
_git_bci() { _git_commit; }
_git_bgrep() { _git_checkout; }
_git_binb() { _git_checkout; }
_git_cat() { _git_checkout; }

_git_discard() { _git_log; }
_git_extract() { _git_log; }
_git_split() { _git_log; }

_git_ff() { __git_complete_remote_or_refspec; }
_git_cmv() { _git_log; }
# _git_file_branch() { _git_checkout "$@"; }
_git_in() { _git_checkout; }
_git_not_merged() { _git_checkout; }
# _git_pop() { _git_checkout; }
_git_dep_push() { _git_push; }
# _git_rebase_all() { _git_checkout; }
_git_remerge() { _git_checkout; }
_git_squash() { _git_checkout; }
