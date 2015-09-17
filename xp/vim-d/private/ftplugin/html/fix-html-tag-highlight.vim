if exists("g:__FIX_HTML_TAG_HIGHLIGHT_vjklfds__")
    finish
endif
let g:__FIX_HTML_TAG_HIGHLIGHT_vjklfds__ = 1

runtime syntax/html.vim

hi link htmlTag Identifier
hi link htmlTagName Normal
hi link htmlArg Type
