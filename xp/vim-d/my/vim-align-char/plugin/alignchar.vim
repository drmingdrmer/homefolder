
let s:special_char = {
      \ " ": '\V\s\ze\S',
      \ }

fun! s:AlignChar(mode) range "{{{
    let chr = input#GetChar('type char> ')
    if has_key(s:special_char, chr)
        let reg = s:special_char[chr]
    else
        let reg = '\V\s\{-}' . chr
    endif
    if a:mode == 'normal'
        return edit#align#VerticalAlign(reg, edit#align#FindParagraph(), virtcol('.'))
    elseif a:mode == 'visual'
        return edit#align#VerticalAlign(reg, [a:firstline, a:lastline], virtcol('.'))
    endif
endfunction "}}}

nnoremap ,a          :call <SID>AlignChar('normal')<CR>
xnoremap ,a          :call <SID>AlignChar('visual')<CR>

" xnoremap ,a          :call edit#align#VerticalAlignVisual('\V \+' . nr2char(getchar()))<CR>
" xnoremap ,af         :call edit#align#VerticalAlignVisual('')<CR>
