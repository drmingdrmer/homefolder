if exists("g:__plugin_xpsnip__")
    finish
endif
let g:__plugin_xpsnip__ = 1

let s:oldcpo = &cpo
set cpo-=< cpo+=B

let xpsnip = {
      \ 'x' : 1,
      \ }

call xpsnip#logging#Init()



let &cpo = s:oldcpo
