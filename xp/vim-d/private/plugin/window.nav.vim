
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

set winwidth=40

let g:xp_window_size = [60, 80, 120, 160]

fun! Win_Switch_Width(...) " {{{

    let curwidth = winwidth(0)

    for w in g:xp_window_size
        if curwidth < w
            exe 'vertical' 'resize' w
            return
        endif
    endfor

    exe 'vertical' 'resize' g:xp_window_size[0]

endfunction " }}}

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

" alt + left hand hjkl to jump to a window
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

" split window
nnoremap <M-4> <C-w><C-v><C-w>=
" close current window
nnoremap <M-1> <C-w>c<C-w>=
