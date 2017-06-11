if exists( "g:__SUPERTAB_CONTINUED_VIM__" )
    finish
endif
let g:__SUPERTAB_CONTINUED_VIM__ = 1

" let g:SuperTabMappingForward = '<Plug>supertabKey'

let g:SuperTabDefaultCompletionType = 'context'
let g:SuperTabContextDefaultCompletionType = '<c-p>'

let g:SuperTabCompletionContexts = ['s:ContextText', 's:ContextDiscover']
let g:SuperTabContextTextOmniPrecedence = ['&omnifunc', '&completefunc']
let g:SuperTabContextDiscoverDiscovery =
    \ ["&completefunc:<c-x><c-u>"]

let g:SuperTabLongestEnhanced = 1
let g:SuperTabNoCompleteAfter=['^','\s']

" SuperTabChain must be called after omnifunc is set.
" But we do not know when it is inited.
autocmd InsertEnter *
    \ if &omnifunc != '' |
    \   call SuperTabChain(&omnifunc, "<c-p>") |
    \ endif
