if exists( "g:__SEARCH_VIM__" )
    finish
endif
let g:__SEARCH_VIM__ = 1

fun! s:CurrentWord() "{{{

    let w = expand("<cword>")
    let w = substitute( w, '\V#', '\\#', 'g' )

    return w

endfunction "}}}

fun! s:CurrentWordCurrentBuf() "{{{
    let w = expand( "<cword>" )
    " let w = shellescape( w )

    let fn = expand( "<cfile>" )
    let fn = shellescape( fn )

    exe "Grep" w fn

endfunction "}}}

" nmap <Plug>search:word_in_cwd :Grep \b<C-r>=<SID>CurrentWord()<CR>\b<CR>
nnoremap <Plug>search:word_in_cwd :Rgrep \b<C-r>=<SID>CurrentWord()<CR>\b<CR>

nnoremap <Plug>search:word_in_cfile :Grep \<<C-r>=<SID>CurrentWord()<CR>\> <C-r>=shellescape( expand( "%" ) )<CR><CR>

