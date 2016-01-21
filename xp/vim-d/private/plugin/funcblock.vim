" if exists("g:__XP_FUNCBLOCK_VIM_jskfdsj")
"     finish
" endif
" let g:__XP_FUNCBLOCK_VIM_jskfdsj = 1

" let b:xp_func_block = [
"       \'\V\ze\<function\>',
"       \'',
"       \'\V\<end\>\zs'
"       \]

fun! s:func_start() "{{{
    if ! exists('b:xp_func_block')
        return
    endif
    let b = b:xp_func_block
    let cur = [line("."), col(".")]
    let [l, c] = searchpairpos(b[0], b[1], b[2], 'bcW')
    if [0, 0] == [l, c] || cur == [l, c]
        call searchpos(b[0], 'bW')
    endif
endfunction "}}}

fun! s:func_end() "{{{
    if ! exists('b:xp_func_block')
        return
    endif
    let b = b:xp_func_block
    let cur = [line("."), col(".")]
    let [l, c] = searchpairpos(b[0], b[1], b[2], 'W')
    " echom 'searchpairpos(' . "'" . join(b, "', '") . "', " . '"W")'
    if [0, 0] == [l, c] || cur == [l, c]
        call searchpos(b[2], 'W')
    endif
endfunction "}}}

nnoremap <Plug>func_start :call <SID>func_start()<CR>
nnoremap <Plug>func_end   :call <SID>func_end()<CR>

com! XpFuncStart :call <SID>func_start()
com! XpFuncEnd :call <SID>func_end()
