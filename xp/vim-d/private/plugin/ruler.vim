let s:rulerType=0

hi CursorColumn cterm=none ctermbg=darkgrey ctermfg=white
fun! s:RulerClear() " {{{
  mat none
  au! CursorHold *
  if v:version > 700
    au! CursorHoldI *
  endif
endfunction " }}}

fun! s:RulerH() " {{{
  let s:rulerType = (s:rulerType ) % 2 + 1
  call s:RulerClear()

  if (s:rulerType == 1)
    au CursorHold  * exe 'mat CursorColumn /\%'.line('.').'l.*/'
    if v:version > 700
      au CursorHoldI * exe 'mat CursorColumn /\%'.line('.').'l.*/'
    endif
    exe 'mat CursorColumn /\%'.line('.').'l.*/'
  endif
  if (s:rulerType == 2)
    au CursorHold  * exe 'mat CursorColumn /\%'.virtcol(".").'v/'
    if v:version > 700
      au CursorHoldI * exe 'mat CursorColumn /\%'.virtcol(".").'v/'
    endif
    exe 'mat CursorColumn /\%'.virtcol(".").'v/'
  endif
endfunction " }}}

" nmap <Leader><Leader>re :call <SID>RulerH()<cr>
" nmap <Leader><Leader>rd :call <SID>RulerClear()<cr>





nmap <Leader><Leader>cl :setlocal cursorline!<cr>
nmap <Leader><Leader>cc :setlocal cursorcolumn!<cr>
