if exists("g:__SUPERINSERT_VIM__")
    finish
endif
let g:__SUPERINSERT_VIM__ = 1



fun! s:Reinit() "{{{
    let b:_xpkey = { 'pos' : [], 'offset' : 0, 'expect' : '' }
endfunction "}}}

fun! s:Init() "{{{
    call s:Reinit()
    let b:_current = []

    let b:__xpsi_plugins__ = []
    let b:__xpsi_plugins__ += [ s:plg_bracket ]
    let b:__xpsi_plugins__ += [ s:plg_bs ]
    let b:__xpsi_plugins__ += [ s:plg_cr ]
    let b:__xpsi_plugins__ += [ s:plg_number ]

endfunction "}}}

fun! s:InitIfNot()
    if !exists( "b:__xpsi_plugins__" )
        call s:Init()
    endif
endfunction

augroup XPsuperInsert
    au!
    au BufRead,BufNewFile,BufNew * call <SID>Init()
    au BufEnter call <SID>InitIfNot()
augroup END


let s:stringSyntaxName  = 'string\|character\|quot\%[e]'
let s:commentSyntaxName = 'comment'
let s:literal = s:stringSyntaxName . '\|' .s:commentSyntaxName

let s:quoterPair = {
            \ '(' : ')',
            \ '[' : ']',
            \ '{' : '}',
            \ '<' : '>',
            \ '"' : '"',
            \ "'" : "'",  
            \ }
let s:rQuoterPair = {
            \ ')' : '(',
            \ ']' : '[',
            \ '}' : '{',
            \ '>' : '<',
            \ '"' : '"',
            \ "'" : "'", 
            \ }

let s:plg_bracket = {}

fun! s:plg_bracket.leftQuoter(key) "{{{

    let [ left, right ] = b:_current

    if a:key =~ '[({\[]'

        let b:_xpkey = {
                    \    'pos' : [ line( "." ), col( "." ) + 2 ], 
                    \    'offset' : -2, 
                    \    'expect' : a:key . '  ' . s:quoterPair[ a:key ] 
                    \}

        " let b:_xpkey = {
                    " \    'pos' : [ line( "." ), col( "." ) + 1 ], 
                    " \    'offset' : -1, 
                    " \    'expect' : a:key . s:quoterPair[ a:key ] 
                    " \}

        let action =  b:_xpkey.expect . "\<left>\<left>"

    else
        let b:_xpkey = { 
                    \    'pos' : [ line( "." ), col( "." ) + 1 ], 
                    \    'offset' : -1, 
                    \    'expect' : a:key . s:quoterPair[ a:key ] 
                    \}
        let action = b:_xpkey.expect

    endif

    return action

endfunction "}}}

fun! s:plg_bracket.rightQuoter(key) "{{{
    echom a:key.'-'
    echom b:_xpkey.expect.'-'
    if b:_current == b:_xpkey.pos 
                \ && b:_xpkey.expect == getline(".")[ b:_current[1] - 1 + b:_xpkey.offset : b:_current[1] - 1 + b:_xpkey.offset + len(b:_xpkey.expect) - 1 ]
                \ && a:key == b:_xpkey.expect[ -1 : -1 ]

        if a:key =~ '[)}\]]'
            let action = "\<bs>\<del>\<right>"
        else
            let action = "\<right>"
        endif


        call s:Reinit()
        return action
    endif

    return 0

endfunction "}}}

fun! s:plg_bracket.checkAndDo(key) "{{{

    if s:SynName() =~? s:literal
        return 0
    endif

    if has_key( s:quoterPair, a:key )
        return self.leftQuoter( a:key )
    elseif has_key( s:rQuoterPair, a:key ) 
        return self.rightQuoter( a:key )
    endif

    return 0

endfunction "}}}



let s:plg_bs = {}
fun! s:plg_bs.checkAndDo(key) "{{{

    if a:key != "\<bs>" || s:SynName() =~? s:literal
        return 0
    endif


    let action = ''

    if b:_current == b:_xpkey.pos 
                \ && b:_xpkey.expect == getline(".")[ b:_current[1] - 1 + b:_xpkey.offset : b:_current[1] - 1 + b:_xpkey.offset + len(b:_xpkey.expect) - 1 ]

        if b:_xpkey.expect =~ '\V[  ]\|(  )\|{  }'
            " let action = "\<bs>\<bs>\<del>\<del>"
            let action = "\<bs>\<del>"
        endif
    endif

    if getline(".")[ b:_current[1] - 2 : b:_current[1] - 1 ] =~ '\V()\|[]\|{}\|""\|' . "''"
        let action = "\<bs>\<del>"
    endif

    if action != ''
        call s:Reinit()
        return action
    endif

    return 0
endfunction "}}}


let s:plg_cr = {}
fun! s:plg_cr.checkAndDo(key) "{{{

    if a:key != "\<cr>" || s:SynName() =~? s:literal
        return 0
    endif


    let action = ''

    if b:_current == b:_xpkey.pos 
                \ && b:_xpkey.expect == getline(".")[ b:_current[1] - 1 + b:_xpkey.offset : b:_current[1] - 1 + b:_xpkey.offset + len(b:_xpkey.expect) - 1 ]
        if b:_xpkey.expect =~ '\V[  ]\|(  )\|{  }'
            let action = "\<bs>\<del>\<cr>\<up>\<end>\<cr>"
        endif
    endif

    " TODO auto string split
    if getline(".")[ b:_current[1] - 2 : b:_current[1] - 1 ] =~ '\V()\|[]\|{}'
        let action = "\<cr>\<up>\<end>\<cr>"
    endif

    if action != ''
        call s:Reinit()
        return action
    endif


    return 0
endfunction "}}}



let s:plg_number = {}
fun! s:plg_number.checkAndDo(key) "{{{
    if b:_current == b:_xpkey.pos 
                \ && b:_xpkey.expect == getline(".")[ b:_current[1] - 1 + b:_xpkey.offset : b:_current[1] - 1 + b:_xpkey.offset + len(b:_xpkey.expect) - 1 ]

        if b:_xpkey.expect =~ '\V[  ]'
            call s:Reinit()
            return "\<bs>\<del>" . a:key
        endif
    endif





    return 0
endfunction "}}}










fun! s:SuperKey(key) "{{{
    " problem that first buffer does NOT trigger Buf* event 
    let post = ''
    if !exists( "b:__xpsi_plugins__" )
        call s:Init()
        let post = "\<C-r>=SuperInsertRedefine()\<cr>"
    endif


    let b:_current = [ line( "." ), col( "." ) ]

    for plg in b:__xpsi_plugins__

        let re = plg.checkAndDo( a:key )

        if type( re ) == type( '' )
            return re . post
        endif

    endfor

    return a:key . post
endfunction "}}}

fun! SuperInsertRedefine()

    fun! s:SuperKey(key) "{{{
        let b:_current = [ line( "." ), col( "." ) ]

        for plg in b:__xpsi_plugins__

            let re = plg.checkAndDo( a:key )

            if type( re ) == type( '' )
                return re
            endif

        endfor

        return a:key
    endfunction "}}}


    return ''
endfunction


" inoremap <expr> (     <SID>SuperKey('(')
" inoremap <expr> [     <SID>SuperKey('[')
" inoremap <expr> {     <SID>SuperKey('{')

" inoremap <expr> )     <SID>SuperKey(')')
" inoremap <expr> ]     <SID>SuperKey(']')
" inoremap <expr> }     <SID>SuperKey('}')


" inoremap <expr> <bs>  <SID>SuperKey("\<BS>")
" inoremap <expr> <cr>  <SID>SuperKey("\<CR>")
" " inoremap <expr> <tab> <SID>SuperTAB()
" " inoremap <expr> <del> <SID>SuperDEL()

" inoremap <expr> 0     <SID>SuperKey('0')
" inoremap <expr> 1     <SID>SuperKey('1')
" inoremap <expr> 2     <SID>SuperKey('2')
" inoremap <expr> 3     <SID>SuperKey('3')
" inoremap <expr> 4     <SID>SuperKey('4')
" inoremap <expr> 5     <SID>SuperKey('5')
" inoremap <expr> 6     <SID>SuperKey('6')
" inoremap <expr> 7     <SID>SuperKey('7')
" inoremap <expr> 8     <SID>SuperKey('8')
" inoremap <expr> 9     <SID>SuperKey('9')



" iunmap (
" iunmap )

" iunmap [
" iunmap ]

" iunmap {
" iunmap }


" iunmap <bs>
" iunmap <cr>
" iunmap <tab>
" iunmap <del>



fun! s:SynName() "{{{
    return synIDattr(synID(b:_current[0], b:_current[1] , 1), "name")
endfunction "}}}
