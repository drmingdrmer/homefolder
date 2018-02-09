if exists( "g:__UTIL_VIM__" )
    finish
endif
let g:__UTIL_VIM__ = 1


fun! StoreWinNr() " {{{
  let s:lastWinnr = winnr()
endfunction " }}}

fun! BackToLast() " {{{
  exe s:lastWinnr . "wincmd w"
endfunction " }}}

com XXStWin call StoreWinNr()
com XXBkWin call BackToLast()


" cursor
fun! StoreCursor() " {{{
  let b:line = line(".")
  let b:cursor = col(".")
endfunction " }}}
fun! BackToLastCursor() " {{{
  call cursor(b:line, b:cursor)
endfunction " }}}

com XXStCur call StoreCursor()
com XXBkCur call BackToLastCursor()



" register
fun! StoreReg() " {{{
  let s:reg0 = @@
endfunction " }}}
fun! RestoreReg() " {{{
  let @@ = s:reg0
endfunction " }}}


fun! RunSelect() " {{{
  normal `<v`>"ly
  " echo @l
  exe @l
endfunction " }}}
vmap <Leader><Leader>rs :call RunSelect()<cr>
nmap <Leader><Leader>rs V:call RunSelect()<cr>


" fun! SaveWinPosition() "{{{
"     let s:winln = winline()
"     let s:line = line( "." )
"     let s:col = col( "." )
" endfunction "}}}

" fun! RestoreWinPosition() "{{{

"   call cursor( s:line, s:col )

"   let winln2 = winline()
"   if winln2 > s:winln
"     exe "normal! " . (winln2-s:winln) . "\<C-e>"
"   elseif winln2 < s:winln
"     exe "normal! " . (s:winln-winln2) . "\<C-y>"
"   endif

" endfunction "}}}
