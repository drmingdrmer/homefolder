if exists( "g:__SUPERTAB_CONTINUED_VIM__" )
    finish
endif
let g:__SUPERTAB_CONTINUED_VIM__ = 1

" let g:SuperTabMappingForward = '<Plug>supertabKey'

let g:SuperTabDefaultCompletionType = 'context'
let g:SuperTabContextDefaultCompletionType = '<c-x><c-u>'

let g:SuperTabCompletionContexts = ['s:ContextText', 's:ContextDiscover']
let g:SuperTabContextTextOmniPrecedence = ['&omnifunc', '&completefunc']
let g:SuperTabContextDiscoverDiscovery =
    \ ["&completefunc:<c-x><c-u>", "&omnifunc:<c-x><c-o>"]

let g:SuperTabLongestEnhanced = 1
let g:SuperTabNoCompleteAfter=['^','\s']
