fun! s:FixStringReturn()
  let synId = synIDattr(synID(line("."), col("."), 1), "name")
  let last = strpart(getline(line(".")), col(".")-1, 1)
  if synId == "javaScriptStringD"  && last != "\"" 
        \|| synId == "javaScriptStringS"  && last != "'" 
        \|| synId == "javaScriptSpecial"
    exe "normal a\\"
  endif
endfunction

inoremap <CR> <esc>:call <SID>FixStringReturn()<CR>a<CR>


