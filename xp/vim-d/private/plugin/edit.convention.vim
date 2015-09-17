if exists("g:__EDIT_CONVENTION_sjfkdsfdjksl__")
    finish
endif
let g:__EDIT_CONVENTION_sjfkdsfdjksl__ = 1

runtime plugin/xp_remap.vim

imap ,      <Plug>xp_remap_comma<Plug>xp_remap_space
imap ,<CR>  <Plug>xp_remap_comma<Plug>xp_remap_cr

fun! s:ClosePum() "{{{
    if pumvisible()
        return "\<C-v>\<C-v>\<BS>"
    else
        return ''
    endif
endfunction "}}}

function! s:PrevBrace() "   {{{
    if col(".") - 1 == strlen(matchstr(getline("."), '^\s*'))
        call cursor(line("."), 1)
        return s:ClosePum()
    endif

    call searchpos('\zs[{("' . "'" . '[]\|^\s\+\zs', 'b', line("."))
    return s:ClosePum()
endfunction " }}}

function! s:NextBrace() "   {{{
    " Might be a bug: with cursor on the last char of a line,
    " searchpos('$', '', line(".")) just returns [0, 0]
    if col(".") == strlen(getline("."))
        return "\<right>" . s:ClosePum()
    endif

    call searchpos('[})"' . "'" . '\]]\zs\|$', '', line("."))
    return s:ClosePum()
endfunction " }}}

inoremap <silent> <C-h> <C-r>=<SID>PrevBrace()<cr>
inoremap <silent> <C-l> <C-r>=<SID>NextBrace()<cr>

" go to after last brace
imap <M-L> <C-c>]}A
