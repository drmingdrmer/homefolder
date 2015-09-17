exe xpsnip#once#init

let s:oldcpo = &cpo
set cpo-=< cpo+=B

fun! xpsnip#ph#New(dic) abort "{{{
    return {
          \ 'name' : dic.name,
          \ }
endfunction "}}}

let &cpo = s:oldcpo
