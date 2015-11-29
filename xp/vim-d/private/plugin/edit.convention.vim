if exists("g:__EDIT_CONVENTION_sjfkdsfdjksl__")
    finish
endif
let g:__EDIT_CONVENTION_sjfkdsfdjksl__ = 1

" remove a space if current line ends with ", "
fun! s:cr_map() "{{{
    let text_before_cursor = strpart(getline("."), 0, col(".")-1)
    if text_before_cursor =~ '\V,\s\$'
        return "\<BS>\<CR>"
    else
        return "\<CR>"
    endif
endfunction "}}}

" <C-]> to expand abbreviation
inoremap ,      <C-]>,<Space>
inoremap <expr> <CR>  <SID>cr_map()

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
