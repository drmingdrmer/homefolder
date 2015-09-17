fun! s:MapAlt(str)
  exe "imap <esc><".a:str."> <M-".a:str.">"
  exe "nmap <esc><".a:str."> <M-".a:str.">"
  exe "vmap <esc><".a:str."> <M-".a:str.">"
endfunction


fun! s:Remap()
  let str = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        \.  "abcdefghijklmnopqrstuvwxyz"
        \.  "0123456789"
        \.  "!@#$%^&*()"
        \.  "+=-,.`;'/"
  let len = strlen(str) | let i = 0
  while (i<len)
    let chr = strpart(str, i, 1)
    let mp = "map <esc>".chr." <M-".chr.">"
    exe "i".mp | exe "n".mp | exe "v".mp
    let i = i + 1
  endwhile

  call s:MapAlt("space")
  call s:MapAlt("cr")
endfunction



" on test server:
" if v:version < 700 && !exists("gui_running") 
  call s:Remap()
" endif


fun! s:RemapFunc()
  let str = "ABC"."DEF"."GHI"."JKL"
  let len = strlen(str) | let i = 1
  while (i <= len)
    let chr = strpart(str, i-1, 1)
    let mp = "map <esc>[[".chr." <F".i.">"
    exe "i".mp | exe "n".mp | exe "v".mp
    let i = i + 1
  endwhile
endfunction

call s:RemapFunc()

" mouse scroll
map ÏB <down>
map ÏA <up>

imap ÏB <down>
imap ÏA <up>


map <F1> <Plug>F1
map <F2> <Plug>F2
map <F3> <Plug>F3
map <F4> <Plug>F4
map <F5> <Plug>F5
map <F6> <Plug>F6
map <F7> <Plug>F7
map <F8> <Plug>F8
map <F9> <Plug>F9
map <F10> <Plug>F10
map <F11> <Plug>F11
map <F12> <Plug>F12



map OP <Plug>F1
map OQ <Plug>F2
map OR <Plug>F3
map OS <Plug>F4
map [15~ <f5>
map [17~ <f6>
map [18~ <f7>
map [19~ <f8>
map [20~ <f9>
map [21~ <f10>
map [22~ <f11>
map [24~ <f12>



" xterm
map ÏP <Plug>F1
map ÏQ <Plug>F2
map ÏR <Plug>F3
map ÏS <Plug>F4
map <F5> <Plug>F5
map <F6> <Plug>F6
map <F7> <Plug>F7
map <F8> <Plug>F8
map <F9> <Plug>F9
map <F10> <Plug>F10
map <F11> <Plug>F11
map <F12> <Plug>F12


fun! s:PrintMap(pre, suf)

  let r = ""

  let str = "1234567890-=\n"
  let str = str . "qwertyuiop[]\\\n"
  let str = str . "asdfghjkl;'\n"
  let str = str . "zxcvbnm, ./\n"

  let len = strlen(str)
  let i = 0
  while i < len
    let _c = strpart(str, i, 1)
    let c = a:pre._c.a:suf
    if _c == "\n"
      let r = r . "\n"
    else
      let mn = mapcheck(c, "n")
      let mv = mapcheck(c, "v")
      let mi = mapcheck(c, "i")
      let r = r . _c . "["

      if mi == "" | let r = r . " " | else | let r = r . "i" | endif
      if mn == "" | let r = r . " " | else | let r = r . "n" | endif
      if mv == "" | let r = r . " " | else | let r = r . "v" | endif

      let r = r . "]  "

    endif
    let i = i + 1
  endwhile

  echo r
  

endfunction

nmap <Leader><Leader>mp :call <SID>PrintMap("<C-", ">")<cr>

