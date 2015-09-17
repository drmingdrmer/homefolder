if exists("g:__autoload_xpsnip_util__")
    finish
endif
let g:__autoload_xpsnip_util__ = 1

let s:oldcpo = &cpo
set cpo-=< cpo+=B

let xpsnip#util#let_sid = 'map <Plug>xsid <SID>|let s:sid=matchstr(maparg("<Plug>xsid"), "\\d\\+_")|unmap <Plug>xsid'

fun! xpsnip#util#GetCmdOutput( cmd ) abort "{{{
    let a = ""

    redir => a
    exe a:cmd
    redir END

    return a
endfunction "}}}
fun! xpsnip#util#Default(k, v) abort "{{{
    let p = 'xpsnip_'
    if !exists( 'g:' . p . a:k )
        exe "let" 'g:'.p.a:k "=" string( a:v )
    endif
endfunction "}}}

let &cpo = s:oldcpo
