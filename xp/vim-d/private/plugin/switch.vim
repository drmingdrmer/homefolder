" if exists( "g:__SWITCH_VIM__" )
"     finish
" endif
" let g:__SWITCH_VIM__ = 1


let s:switches = [
      \ 'y|n',
      \ 'yes|no',
      \ '1|0',
      \ 'true|false',
      \ 'on|off',
      \ 'up|down',
      \ 'left|right',
      \ 'top|bottom',
      \ 'high|low',
      \ '-|+',
      \ '==|!=',
      \ '=~|!~',
      \ '=~?|!~?',
      \ '=~#|!~#',
      \ '>|<',
      \ '>=|<=',
      \]

let s:mapping = {}
fun! s:CreateMap() "{{{

    for def in s:switches

        call s:Defit( def )

        let def = substitute( def, '\V\<\w', '\u\0', 'g' )
        call s:Defit( def )

        let def = substitute( def, '\V\.', '\u\0', 'g' )
        call s:Defit( def )

    endfor

endfunction "}}}

fun! s:SwitchWord( w ) "{{{

    if has_key( s:mapping, a:w )

        let i = index( s:mapping[ a:w ], a:w )
        
        return s:mapping[ a:w ][ ( i + 1 ) % len( s:mapping[ a:w ] ) ]

    endif
endfunction "}}}

fun! s:GetCurrentWord() "{{{
    let l = getline( line( "." ) )

    if l == ''
        return [ '', 0, 0 ]
    endif

    " word start and word end

    let curChar = len( l ) > 0 ? l[ col( "." ) - 1 ] : ''
    
    let cur = [ line( "." ), col( "." ) ]


    if curChar =~ '\V\w'

        let end = searchpos( '\V\w\ze\(\W\|\s\|\$\)', 'c', cur[ 0 ] )
        let start = searchpos( '\V\(\W\|\s\|\^\)\zs\w', 'cb', cur[ 0 ] )

    else

        let end = searchpos( '\V\W\ze\(\w\|\s\|\$\)', 'c', cur[ 0 ] )
        let start = searchpos( '\V\(\s\|\s\|\^\)\zs\W', 'cb', cur[ 0 ] )

        " let end = searchpos( '\V\w\|\s\|\$', '', cur[ 0 ] )
        " let start = searchpos( '\V\w\|\s\|\^', 'b', cur[ 0 ] )

    endif

    call cursor( cur )

    let [ s, e ] = [ start[ 1 ], end[ 1 ] ]

    return [ l[ s - 1 : e - 1 ], s, e ]

endfunction "}}}

fun! s:Swtich() "{{{

    let [ word, s, e ] = s:GetCurrentWord()

    if word != ''

        let sword = s:SwitchWord( word )

        if sword isnot 0

            let cur = [ line( "." ), col( "." ) ]

            let l = getline( line( "." ) )

            let leftPart = s == 1 ? '' : l[ 0 : s - 1 - 1 ]
            let newline = leftPart . sword . l[ e - 1 + 1 : ]

            call setline( cur[ 0 ], newline )
            call cursor( cur )
        endif

    endif
endfunction "}}}


fun! s:Defit( def ) "{{{

    let elts = split( a:def, '\V|' )

    for e in elts
        let s:mapping[ e ] = elts
    endfor

endfunction "}}}

call s:CreateMap()

" nnoremap <silent> <Plug>eidt:switch_word :silent! call <SID>Swtich()<CR>
nnoremap <silent> <Plug>edit:switch_word :call <SID>Swtich()<CR>

