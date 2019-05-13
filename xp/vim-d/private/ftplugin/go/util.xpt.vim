XPTemplate priority=sub

let s:f = g:XPTfuncs()

" use snippet 'varConst' to generate contant variables
" use snippet 'varFormat' to generate formatting variables
" use snippet 'varSpaces' to generate spacing variables


XPTinclude
      \ _common/common

XPT slclone " clone a slice
`to^ = append(`from^[:0:0], `from^...)
