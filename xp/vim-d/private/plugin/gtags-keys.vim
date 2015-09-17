if exists("g:__GTAGS_KEYS_VIM__")
    finish
endif
let g:__GTAGS_KEYS_VIM__ = 1


nnoremap <Plug>edit:gtags:goto-definition :Gtags <C-r>=expand("<cword>")<CR><CR>
nnoremap <Plug>edit:gtags:goto-reference  :Gtags -r <C-r>=expand("<cword>")<CR><CR>

" nnoremap <Plug>edit:gtags:goto-definition-preview
