" if exists("g:__XP_FUNCBLOCK_VIM_jskfdsj")
"     finish
" endif
" let g:__XP_FUNCBLOCK_VIM_jskfdsj = 1

" let b:xp_func_block = [
"       \'\V\ze\<function\>',
"       \'',
"       \'\V\<end\>\zs'
"       \]

fun! s:goto_(flg) "{{{
    if ! exists('b:xp_func_block')
        return
    endif
    let b = b:xp_func_block
    let cur = [line("."), col(".")]
    let [l, c] = searchpairpos(b[0], b[1], b[2], a:flg . 'cW')
    if [0, 0] == [l, c] || cur == [l, c]
        call searchpos(b[0], a:flg . 'W')
    endif
endfunction "}}}
fun! s:func_start() "{{{
    call s:goto_('b')
endfunction "}}}

fun! s:func_end() "{{{
    call s:goto_('')
endfunction "}}}

nnoremap <Plug>func_start :call <SID>func_start()<CR>
nnoremap <Plug>func_end   :call <SID>func_end()<CR>
