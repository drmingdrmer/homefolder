if exists( "g:__RC_PLUGINS__TAGLIST_VIM__" )
    finish
endif
let g:__RC_PLUGINS__TAGLIST_VIM__ = 1

let Tlist_Use_Right_Window   = 1
let Tlist_WinWidth           = 30
let Tlist_Enable_Fold_Column = 0

"actionscript language
let tlist_actionscript_settings = 'actionscript;c:class;f:method;p:property;v:variable'

if has("win32")
    let Tlist_Ctags_Cmd = "C:/Hyper.Disc/.soft/.tool/ec56w32/ctags56/ctags.exe"
endif
