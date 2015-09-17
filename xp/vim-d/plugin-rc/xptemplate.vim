if exists( "g:once_rc_plugins_xptemplate_j3k4l32j4lk" )
    finish
endif
let g:once_rc_plugins_xptemplate_j3k4l32j4lk = 1

fun! WhatifCheckPosition() "{{{
    call s:WhatifInit()
    let pos = { 'l' : line( "." ), 'c' : col( "." ) }

    " echom string( [ pos, b:_xp_pum_.pos ] )

    if pos == b:_xp_pum_.pos

    else
        " echom 'something matched, reset'
        " something matched
        call s:WhatifReset()
    endif
    

    return ''
endfunction "}}}

fun! s:WhatifPre() "{{{
    call s:WhatifInit()
    let b:_xp_pum_.pos = { 'l' : line( "." ), 'c' : col( "." ) }
    return ''
endfunction "}}}

fun! s:Whatif() "{{{

    call s:WhatifInit()

    let b:_xp_pum_.count += 1
    " echom string( b:_xp_pum_ )


    if b:_xp_pum_.count < 2
        return "\<C-v>\<C-v>\<BS>\<C-r>=WhatifCheckPosition()\<CR>"
    else
        let b:_xp_pum_.count = 0
        " force pum
        return "\<C-n>\<C-p>"
    endif

endfunction "}}}

fun! s:WhatifInit() "{{{
    if !exists( 'b:_xp_pum_' )
        let b:_xp_pum_ = { 'count' : 0, 'pos' : { 'l' : 0, 'c' : 0 } }
    endif
endfunction "}}}

fun! s:WhatifReset() "{{{
    call s:WhatifInit()
    let b:_xp_pum_ = { 'count' : 0, 'pos' : { 'l' : 0, 'c' : 0 } }
endfunction "}}}

augroup DualPum
    au!

    au InsertEnter * call s:WhatifReset()

augroup END

inoremap <silent> <Plug>MyAfterPum <C-r>=<SID>Whatif()<CR>
inoremap <silent> <Plug>MyPrePum <C-r>=<SID>WhatifPre()<CR>

fun! s:def( k, v ) "{{{
    let key = 'g:xptemplate_' . a:k
    if ! exists( key )
       exe "let" key "=" string( a:v )
    endif
endfunction "}}}

call s:def( 'vars', "author=drdr.xp&email=drdr.xp@gmail.com&PYTHON_EXP_SYM= as &SParg=" )
" let g:xptemplate_debug_log = '~/xpt.log'
let g:xptemplate_pum_quick_back = 0
let g:xptemplate_cwd_snippet = 1
let g:xptemplate_strict = 2
let g:xptemplate_close_pum = 1
let g:xptemplate_minimal_prefix = '1,full'
" let g:xptemplate_highlight='current,following,next'
let g:xptemplate_highlight=''
let g:xptemplate_break_undo = 1
let g:xptemplate_highlight_nested=1
let g:xptemplate_brace_complete = 1
let g:xptemplate_nav_next = '<C-l>'
let g:xptemplate_to_right = '<M-l>'
" let g:xptemplate_ph_pum_accept_empty = 1
" let g:xptemplate_bundle = 'javascript_jquery'
" let g:xptemplate_always_show_pum = 1

let g:xptemplate_key = '<Tab>'
let g:xptemplate_pum_tab_nav = 1

" xpt wrap supertab
let g:SuperTabMappingForward = '<Plug>xpt_void'

" Tell XPTemplate what to fall back to, if nothing matches.
" Original SuperTab() yields nothing if g:SuperTabMappingForward was set to
" something it does not know.
let g:xptemplate_fallback = '<C-r>=XPTwrapSuperTab("n")<CR>'

fun! XPTwrapSuperTab(command) "{{{
    let v = SuperTab(a:command)
    if v == ''
        return "\<Tab>"
    else
        return v
    end
endfunction "}}}
