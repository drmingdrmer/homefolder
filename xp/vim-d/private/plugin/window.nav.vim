
set noequalalways
set winminheight=0

let s:idPre = reltime()[0]
if !exists("s:NamedWinId")
  let s:NamedWinId = 1
endif

fun! s:UpdateWinName() "{{{
  let oldid = getwinvar(winnr(), "id")
  if !oldid || oldid !~ "^".s:idPre."-"
    call setwinvar(winnr(), "id", s:idPre."-".s:NamedWinId)
    let s:NamedWinId += 1
  endif
endfunction "}}}

fun! s:FindWinByName(name) "{{{
  let nwin = winnr("$")
  let i = 1
  while i <= nwin
    if a:name == getwinvar(i, "id")
      return i
    endif
    let i += 1
  endwhile

  " echo "cnt find name :".a:name
  return 0
endfunction "}}}

let s:LastWinName = ""

fun! WinId() "{{{
    let ident = getwinvar(winnr(), "id")
    if ident == ""
        call s:UpdateWinName()
        let ident = getwinvar(winnr(), "id")
    endif
    return ident
endfunction "}}}

fun! WinGoto( ident ) "{{{
  let wr = s:FindWinByName(s:LastWinName)
  exe wr."wincmd w"
endfunction "}}}

fun! s:WinRem() "{{{
    let s:LastWinName = WinId()
endfunction "}}}

fun! s:WinBack() "{{{
  let wr = s:FindWinByName(s:LastWinName)
  exe wr."wincmd w"
endfunction "}}}

com! WinRem silent call <SID>WinRem()
com! WinBack silent call <SID>WinBack()

let s:miniWinHeight = 10
fun! s:Win_Resize_To_Tiny() " {{{
  if bufname("%") =~ "^-.*-$"
    return
  endif
  if (winheight(0) < s:miniWinHeight)
    exe "resize ".s:miniWinHeight
  endif
endfunction " }}}

let g:nice_win_width = &columns * 618 / 1000
let g:tiny_win_width = 40

let s:winWidths = {}

fun! s:winWidths.W0() "{{{
    return min( [ 85, &columns - 4 ] )
endfunction "}}}
fun! s:winWidths.W1() "{{{
    return min( [ 120, &columns - 4 ] )
endfunction "}}}
fun! s:winWidths.W2() "{{{
    return &columns * 618 / 1000
endfunction "}}}

fun! Win_Switch_Width(...) " {{{

    let curwidth = winwidth(0)

    for i in [ 0, 1, 2 ]
        let exp = s:winWidths['W' . i]()
        let exp = exp / 5 * 5
        if exp > curwidth
            exe "vertical resize ".exp
            return
        endif
    endfor

    let exp = s:winWidths[ 'W0' ]()
    exe "vertical resize ".exp

endfunction " }}}

fun! Win_LR_Switch() " {{{
  let cur = winnr()
  wincmd l
  let cur2 = winnr()
  if cur == cur2
    wincmd h
  endif
endfunction " }}}

" switch window
nmap <M-q> :call Win_LR_Switch()<CR>:exe "vertical res ".g:nice_win_width<CR>
" nmap <M-w><M-w> <C-w><C-w>:vertical res 100<CR>zzze

" swith up/down & to full height
fun! s:SwitchVertWin(isUp) " {{{
  " call confirm ("...")
  let h = winheight(0)
  if a:isUp
    wincmd k
  else
    wincmd j
  endif
  exe h."wincmd _"
endfunction " }}}
nmap <C-w><C-k> :call <SID>SwitchVertWin(1)<CR>
nmap <C-w><C-j> :call <SID>SwitchVertWin(0)<CR>

nmap <C-w><C-j> <C-w>r<F1>
nmap <C-w><C-k> <F2><C-w>R
nmap <F8>       <C-w>r<F1>
nmap <F7>       <F2><C-w>R

nmap <Plug>F1 :call <SID>SwitchVertWin(1)<CR>
nmap <Plug>F2 :call <SID>SwitchVertWin(0)<CR>

nmap <Leader><Leader><Leader>wildwindow :call Win_Switch_Width(2)<CR>zzze

" upper/lower window in tiny size

nmap <M-a> <C-w>h
nmap <M-f> <C-w>l
nmap <M-d> <C-w>j:call <SID>Win_Resize_To_Tiny()<CR>
nmap <M-s> <C-w>k:call <SID>Win_Resize_To_Tiny()<CR>

nmap <C-Up> <M-s>
nmap <C-Down> <M-d>

" full size
nmap <C-w><C-f> <C-w>_

" small size
nmap <C-w><C-n> z10<CR>

" switch width size
nmap W :call Win_Switch_Width(0)<CR>


" vertical resize
nmap <M-=> 4<C-w>+
nmap <M--> 4<C-w>-

" horizontal resize
nmap <M-0> 4<C-w>>
nmap <M-9> 4<C-w><
