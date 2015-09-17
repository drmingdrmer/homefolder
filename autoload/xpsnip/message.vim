if exists("g:__autoload_xpsnip_message__")
    finish
endif
let g:__autoload_xpsnip_message__ = 1

let s:oldcpo = &cpo
set cpo-=< cpo+=B

fun! xpsnip#message#Info( msg ) "{{{
    echom a:msg
endfunction "}}}
fun! xpsnip#message#Warn( msg ) "{{{
    echohl WarningMsg
    echom a:msg
    echohl
endfunction "}}}
fun! xpsnip#message#Error( msg ) "{{{
    echohl ErrorMsg
    echom a:msg
    echohl
endfunction "}}}

let &cpo = s:oldcpo
