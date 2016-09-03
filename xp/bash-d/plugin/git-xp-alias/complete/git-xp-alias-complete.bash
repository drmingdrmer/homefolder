# completion extension to git-completion.bash

_git_l() { _git_log; }
_git_rm_branch() { _git_branch; }

__git_complete gl  _git_log
__git_complete gll _git_log
__git_complete gld _git_log
__git_complete gh  _git_log

