# completion extension to git-completion.bash

_git_l() { _git_log; }
_git_rm_branch() { _git_branch; }

__git_complete ,d  _git_diff
__git_complete gl  _git_log
__git_complete gll _git_log

_git_comma()
{
  # local _cur=${COMP_WORDS[COMP_CWORD]}
  local cc=${COMP_WORDS[1]}
  local shortcut=$(, get_shortcut "$cc" 2>/dev/null)
  case $shortcut in

      ra|rc|ri|rp|rr) _git_rebase ;;
      a*)          _git_add    ;;
      d|sf)        _git_diff   ;;
      3|f|g|l)     _git_log    ;;
      mc|mf)       _git_merge  ;;

      *)
          COMPREPLY=( $( compgen -W "$(, list_shortcut)" -- $cc ) )
          ;;
  esac
}
__git_complete ,  _git_comma

