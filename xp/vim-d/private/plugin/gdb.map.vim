let s:toggleGdb = 0 
fun! s:MapGdb()
  let s:toggleGdb = 1-s:toggleGdb
  if s:toggleGdb 
    nmap <down> :Ide next<cr>
    nmap <right> :Ide step<cr>
    nmap && :Ide display <c-r>=expand("<cword>")<cr><cr>
    nmap &* :Ide display *<c-r>=expand("<cword>")<cr><cr>
    nmap &1 :Ide display *<c-r>=expand("<cword>")<cr><cr>
    nmap &2 :Ide display **<c-r>=expand("<cword>")<cr><cr>
    nmap &3 :Ide display ***<c-r>=expand("<cword>")<cr><cr>
    nmap &d :Ide delete display 
    nmap &a :Ide display<cr>
    vmap && y:<c-w>Ide display <c-r>=@@<cr><cr>
    vmap &* y:<c-w>Ide display *<c-r>=@@<cr><cr>
    vmap &1 y:<c-w>Ide display *<c-r>=@@<cr><cr>
    vmap &2 y:<c-w>Ide display **<c-r>=@@<cr><cr>
    vmap &3 y:<c-w>Ide display ***<c-r>=@@<cr><cr>
    nmap &l :Ide info local<cr>
    nmap &t :Ide ptype <c-r>=expand("<cword>")<cr><cr>
    nmap $$ :Ide bt<cr>
    nmap $u :Ide up<cr>
    nmap $d :Ide down<cr>
  else
    nunmap <down>
    nunmap <right>
    nunmap &&
    nunmap &*
    nunmap &1
    nunmap &2
    nunmap &3
    nunmap &d
    nunmap &a
    vunmap &&
    vunmap &*
    vunmap &1
    vunmap &2
    vunmap &3
    nunmap &l
    nunmap &t
    nunmap $$
    nunmap $u
    nunmap $d
  endif
endfunction


nmap <Leader><Leader>tg :call <SID>MapGdb()<cr>
