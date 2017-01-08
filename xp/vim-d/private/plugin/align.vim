" splitParam : 1 - split param
             " 2 - add blank line to splited func dec
fun! Al(splitParam) range
  '>+1
  normal mx

  

  "remove end-line blank
  silent! '<,'x-1s/\s*$//g
  " remove blank wrapping quoter
  silent! '<,'x-1s/\s*(\s*/(/g
  " add space around *
  silent! '<,'x-1s/\s*\*\s*/ * /g
  silent! '<,'x-1s/\*\s\+/*/g
  " silent! '<,'x-1s/\*\s\+\*/**/g
  " add pseudo *

  if a:splitParam == 0
    " join lines
    silent! '<,'x-1g/\(,\|(\)$/j
  elseif a:splitParam == 1
    " split func if longer than 80 chars
    silent! '<,'x-1g/.\%>80v/s/,/\0\r/g
  elseif a:splitParam == 2
    " split func if longer than 80 chars, & create blank line between funcs
    silent! '<,'x-1g/.\%>80v/s/,\|$/\0\r/g
  elseif a:splitParam == 3
    " split every argument
    silent! '<,'x-1g/./s/,\|$/\0\r/g
  endif

  " add pseudo func dec
  silent! '<,'x-1s/\(,\|(\)$\n/\1\rxxx xxx (/g
  " remove leading space
  silent! '<,'x-1s/^\s*/ /
  " remove unnecessary space
  silent! '<,'x-1s/\(\s\|(\)\s*/\1/g
  AlignCtrl p0P0
  AlignCtrl rrrll 
  " use first line's white space
  AlignCtrl I

  " align head
  AlignCtrl l
  AlignCtrl C \(const\|static\|\s\)\+
        \ \<\(void\|char\|int\|long\|short\|signed\|unsigned\|\w\|\(struct\s\+\w\+\)\|\s\)\+\s
        \ \w\+
        \ (
        \ )
  '<,'x-1Align
  " AlignCtrl C \(const\|static\|\s\)\{1,}
        " \ \<\(void\|char\|int\|long\|short\|signed\|unsigned\|\w\|\(struct\s\+\w\+\)\|\*\|\s\)\+\s
        " \ (
        " \ )
  " '<,'x-1Align

  " AlignCtrl C ( \(\*\|const\|static\)\{1,}
  " '<,'x-1Align

  " remove pseudo fun dec
  silent! '<,'x-1s/^\(\s*\)xxx\(\s*\)xxx\(\s*\)(/\1   \2   \3 /
  " remove blank in empty bracket
  silent! '<,'x-1s/(\s*)/()/g
  silent! '<,'x-1s/^\s\s//
  silent! '<,'x-1s/\s*)/)/
  silent! '<,'x-1s/\s*(/ (/

  set nohlsearch
endfunction

"map{{{
vmap <Plug>format:c:1_func_1_line   :call Al(0)<cr>
vmap <Plug>format:c:func_split_80   :call Al(1)<cr>
vmap <Plug>format:c:func_with_blank :call Al(2)<cr>
vmap <Plug>format:c:func_split_args :call Al(3)<cr>
"map}}}


let s:special_char = {
      \ " ": '\V \+\S',
      \ }

fun! s:AlignChar() "{{{
    let chr = input#GetChar()
    if has_key(s:special_char, chr)
        let reg = s:special_char[chr]
    else
        let reg = '\V\s' . chr
    endif
    return edit#align#VerticalAlign(reg, edit#align#FindParagraph(), virtcol('.'))
endfunction "}}}

xnoremap ,a<Space>   :call edit#align#VerticalAlignVisual('\V \+\S')<CR>
" nnoremap ,a          :call edit#align#VerticalAlign('\V \+\S', edit#align#FindParagraph(), virtcol('.'))<CR>
nnoremap ,a          :call <SID>AlignChar()<CR>
" xnoremap ,aa         :call edit#align#VerticalAlignVisual('\V \+' . nr2char(getchar()))<CR>
" xnoremap ,af         :call edit#align#VerticalAlignVisual('')<CR>
