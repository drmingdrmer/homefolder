if exists( "b:__FTPLUGIN_VIM_VIM__" )
    finish
endif
let b:__FTPLUGIN_VIM_VIM__ = 1


if !has( "gui_running" )
  finish
endif



let s:fn = substitute( expand("%:p"), '\\', '/', 'g' )

if s:fn !~ '/\%(colors\|syntax\)/.*\.vim$'
    finish
endif

runtime! macro/colorEdit.vim
