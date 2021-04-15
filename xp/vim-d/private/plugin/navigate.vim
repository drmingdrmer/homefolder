if exists("g:__XP_PLUGIN_NAVIGATE_VIM__")
    finish
endif
let g:__NAVIGATE_VIM__ = 1


if ''==mapcheck("<Plug>(navigate:error_next)", "n") | nnoremap <Plug>(navigate:error_next)        :cn<CR>| endif
if ''==mapcheck("<Plug>(navigate:error_prev)", "n") | nnoremap <Plug>(navigate:error_prev)        :cp<CR>| endif
