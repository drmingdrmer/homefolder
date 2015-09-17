if exists( "g:__PYINDENT_XP_VIM__" )
    finish
endif
let g:__PYINDENT_XP_VIM__ = 1


fun! g:Pyindent_nested_paren_func( lnum )
    echom "Pyindent_nested_paren_func"



    call cursor( a:lnum, 1 )

    " echom string( [ a:lnum, col( "." ), line( "." ) ] )

    let pp = searchpairpos('(\|{\|\[', '', ')\|}\|\]', 'bWcn',
          \ "line('.') < " . (a:lnum - 1000) . " ? dummy :"
          \ . " synIDattr(synID(line('.'), col('.'), 1), 'name')"
          \ . " =~ '\\(Comment\\|String\\)$'" )

    " echom string( [ a:lnum, line( "." ),  col( "." ), pp ] )
    if pp == [0, 0]
        if getline( a:lnum ) =~ '\V\^\s\*\[([{]'
            " echom 'current line=' . a:lnum
            return &sw * 2
        endif
    endif

    " echom string( pp )

    if getline( a:lnum ) =~ '\V\^\s\*\[\])}]'
        return 0
    endif


    let [ line, column ] = pp

    let afterQuote = getline( line )[ column :  ]

    if afterQuote =~ '\V\^\s\*\$'
        return s:IIndent()
    endif



    let pp[1] = pp[1] - indent( pp[0] )
          \ + len( matchstr( getline( pp[0] )[ pp[1] : ], '\V\^\s\*' ) )


    return pp[1]
endfunction


fun! g:Pyindent_open_paren_func( lnum )
    echom "Pyindent_open_paren_func"

    if getline( a:lnum ) =~ '\V\^\s\*\[[{]'
        return s:IIndent()
    endif


    call cursor( a:lnum, 1 )

    " echom string( [ a:lnum, col( "." ), line( "." ) ] )

    let pp = searchpairpos('(\|{\|\[', '', ')\|}\|\]', 'bWcn',
          \ "line('.') < " . (a:lnum - 1000) . " ? dummy :"
          \ . " synIDattr(synID(line('.'), col('.'), 1), 'name')"
          \ . " =~ '\\(Comment\\|String\\)$'" )

    " echom string( [ a:lnum, line( "." ),  col( "." ), pp ] )
    if pp == [0, 0]
        return 0
    endif

    let [ line, column ] = pp

    let afterQuote = getline( line )[ column :  ]

    if afterQuote =~ '\V\^\s\*\$'
        return s:IIndent()
    endif


    let pp[1] = pp[1] - indent( pp[0] )
          \ + len( matchstr( getline( pp[0] )[ pp[1] : ], '\V\^\s\*' ) )


    return pp[1]
endfunction

fun! s:IIndent() "{{{
    return &sw * 2
endfunction "}}}

