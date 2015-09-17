fun! s:InserDate()
  let date = strftime("%y-%m-%d ")
  exe "normal i".date
endfunction

nmap ,id :call <SID>InserDate()<cr>
nmap ,it i<C-r>=strftime("%H:%M")<cr>

