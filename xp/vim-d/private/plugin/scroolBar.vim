let s:barStart = 0
let s:barEnd = 0

fun! WinScr(len, onlySymbol, updateSign) " {{{
  let winh = winheight(0)
  let winline = winline()
  let curl = line(".")
  let bufl = line("$")

  let topBufLine = curl - winline + 1

  let bottomBufLine = topBufLine + winh -1
  if bottomBufLine > bufl
    let bottomBufLine = bufl
  endif

  " echo topBufLine." ". bottomBufLine

  let barStart = topBufLine * a:len / bufl
  let barEnd = bottomBufLine * a:len / bufl

  "for sign
  let s:barStart =    topBufLine * winh / bufl + topBufLine
  let s:barEnd   = bottomBufLine * winh / bufl + topBufLine

  if barStart >= barEnd
    let barEnd = barEnd + 1
  endif

  let s = ""
  let i = 0

  " chars before bar
  while i < barStart
    let s = s." "
    let i = i + 1
  endwhile

  " percentage
  let v = ""
  if !a:onlySymbol
    let v = "".(curl * 100 / bufl)
    let vlen = strlen(v)
    if v == "0" 
      " head
      let v = "<<"
    elseif vlen == 1
      " only 1 digit
      let v = "0".v
    elseif vlen == 3
      " tail
      let v = ">>"
    endif

    let i = i + 2
    " bar chars if any
    while i < barEnd
      let v = "=".v
      let i = i + 1
      if i < barEnd
        let v = v."="
        let i = i + 1
      endif
    endwhile
  else
    while i < barEnd
      let v = v."*"
      let i = i + 1
    endwhile
  endif

  let s = s.v

  " chars after bar
  while i < a:len
    let s = s." "
    let i = i + 1
  endwhile

  return s

endfunction " }}}

" set statusline=%{WinScr(20,1)}

hi ScrollBar cterm=none ctermfg=white ctermbg=white
sign define scrollBarStart text=__ texthl=ScrollBar
sign define scrollBarBody text=|| texthl=ScrollBar
sign define scrollBarEnd text=\\ texthl=ScrollBar

fun! s:UpdateScrollBar()

  call s:UpdateScrollWin()
  return
endfunction


fun! s:UpdateScrollWin() " {{{

  if bufname("%") == s:ScrollWinName || &filetype =~ "qf"
    return
  endif

  if !exists("b:scrollLastLine")
    let b:scrollLastLine=-1
  endif

  let curln = line(".")-winline()+1
  if b:scrollLastLine == curln
    return
  endif

  let b:scrollLastLine = curln

  call StoreWinNr()
  let s:curReg = @"

  let height = winheight(0)
  let str = WinScr(height, 1, 0)

  let slf = winnr()
  let lastw = -1
  let tp = 0
  while lastw != winnr()
    let lastw = winnr()
    wincmd k
    if lastw != winnr()
      let tp = tp + winheight(0) + 1
    endif
  endwhile


  exe slf."wincmd w"
  call BackToLast()

  let str = repeat("-", tp).str

  call s:GotoScrollWin()

  setlocal modifiable | setlocal noreadonly

  normal ggVGd
  call append(0, str)
  %s/./\0\0\r/g
  normal Gddddgg

  setlocal nomodifiable | setlocal readonly

  " echo tp

  call BackToLast()
  let @" = s:curReg
endfunction " }}}

let s:ScrollWinName = "-scrollbar-"

fun! s:GotoScrollWin() " {{{
  let lst = winnr()
  let n = bufwinnr(s:ScrollWinName)
  if n != -1
    exe n."wincmd w"
    wincmd L
    2wincmd |
    return
  endif

  " create win
  exe "bo 2vnew ".s:ScrollWinName
  2wincmd |
  setlocal nobuflisted
  setlocal readonly
  setlocal nomodifiable
  setlocal nonumber
  setlocal nolist
  setlocal wrap
  setlocal foldcolumn=0
  setlocal buftype=nofile
  setlocal nocursorline
  syntax match ScrollBar /\*/

endfunction " }}}

" 
nmap 99rt :call <SID>UpdateScrollWin()<cr>



augroup WS
  au!
augroup END

fun! s:Enable() "{{{
  au WS CursorHold * call <SID>UpdateScrollBar()
  au WS WinEnter * call <SID>UpdateScrollBar()
  nnoremap <C-d> <C-d>:call <SID>UpdateScrollBar()<cr>
  nnoremap <C-u> <C-u>:call <SID>UpdateScrollBar()<cr>
  nnoremap n n:call <SID>UpdateScrollBar()<cr>
  nnoremap N N:call <SID>UpdateScrollBar()<cr>
endfunction "}}}

fun! s:Disable()
  " sign unplace *
  au! WS
  nunmap <C-d>
  nunmap <C-u>
  nunmap n
  nunmap N
endfunction
nmap <Leader><Leader>scn :call <SID>Enable()<cr>
nmap <Leader><Leader>scu :call <SID>Disable()<cr>



