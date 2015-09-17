setlocal tabstop=8 shiftwidth=4 softtabstop=4
setlocal complete-=i

" setlocal foldmethod=indent


let s:ptn = '\V\^\s\*def\s\w'

fun! s:GotoFuncDec(flag) "{{{
    let cur = [line("."), col(".")]
    let line = search(s:ptn, 'W' . a:flag)
endfunction "}}}

fun! s:LessIndentOrEOF(indentNr, flag) "{{{
    normal! j
    " echom a:indentNr
    let cur = [line("."), col(".")]
    let line = search('\V\^\ze\s\*\%<' . a:indentNr . 'v\S\|\%$', 'W' . a:flag)
    " echom line
endfunction "}}}

fun! s:NonBlank(flag) "{{{
    let cur = [line("."), col(".")]
    let line = search('\V\^\s\*\S', 'W' . a:flag)
endfunction "}}}

nnoremap <buffer> <Plug>edit:searchFuncStartForw  :call <SID>GotoFuncDec('')<CR>
nnoremap <buffer> <Plug>edit:searchFuncStartBack  :call <SID>GotoFuncDec('b')<CR>

nnoremap <buffer> <Plug>edit:searchFuncEndForw  :call <SID>GotoFuncDec('cb')<CR>:call <SID>LessIndentOrEOF(indent('.') + 2, '')<CR>:call <SID>NonBlank('b')<CR>
nnoremap <buffer> <Plug>edit:searchFuncEndBack  :call <SID>GotoFuncDec('cb')<CR>:call <SID>GotoFuncDec('b')<CR>:call <SID>LessIndentOrEOF(indent('.') + 2, '')<CR>:call <SID>NonBlank('b')<CR>

nmap <buffer> ]]  <Plug>edit:searchFuncStartForw
nmap <buffer> [[  <Plug>edit:searchFuncStartBack

nmap <buffer> ][  <Plug>edit:searchFuncEndForw
nmap <buffer> []  <Plug>edit:searchFuncEndBack










fun! s:MoveFunc( direction )
    let cur = [ line( "." ), col( "." ) ]
    normal ]]m'
    normal [[
    if getline( "." ) =~ '^\s*def\s'
        normal! V''
        call search( '\S', 'bW' )
        if getline( line( "." ) + 1 ) =~ '^\s*$'
            normal! j
        endif

        normal! d
        if a:direction == 'down'
            if getline( "." ) =~ '^\s*$'
                normal ]]
            endif
            normal ]]
            normal! P
        else
            normal [[
            normal! P

        endif

    endif
endfunction


nnoremap <buffer> <M-J> :call <SID>MoveFunc( 'down' )<CR>
nnoremap <buffer> <M-K> :call <SID>MoveFunc( 'up' )<CR>
