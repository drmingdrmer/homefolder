if exists("g:__XP__PLUGIN__DOC_VIM__")
    finish
endif
let g:__XP__PLUGIN__DOC_VIM__ = 1


if ''==mapcheck("<Plug>(doc:ref)", "n")
    nnoremap     <Plug>(doc:ref)        K
endif
