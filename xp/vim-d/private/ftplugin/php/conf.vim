let b:strConnector = "."
fun! s:SwitchDollar()
  let _isk = &isk
  if _isk =~ ',\$'
    let &isk = substitute(_isk, ',\$', '', '')
  else
    set isk+=$
  endif
endfunction

nmap <buffer> <Leader><Leader>4 :call <SID>SwitchDollar()<cr>
nmap <buffer> <Space>r :!php %<cr>

setlocal foldmethod=marker
setlocal foldmarker={,}
setlocal foldlevel=10

set complete=.,w,b,u,i

