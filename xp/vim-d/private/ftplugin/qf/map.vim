hi CurrentQFPosition cterm=none ctermbg=green 

let s:id=1
sign define curPos text=>> linehl=MarkWord1

fun! s:Jump()
  call StoreWinNr()
  if strpart(getline(line(".")), 0, 2) == "||"
    return
  endif
  " exe 'syn match CurrentQFPosition /\%'.line('.').'l.*/'

  " echo line(".")

  let fn = expand("<cfile>")
  " echo fn

  let line=getline(line("."))
  let ln = matchstr(line, '|\@<=\d\+|\@=')
  " echo ln
  exe "sign place ".(3-s:id)." line=".ln." name=curPos file=".fn
  " exe "sign jump ".(3-s:id)." file=".fn
  exe "normal! \<cr>zR"
  exe "sign unplace ".s:id
  let s:id=3-s:id
  call BackToLast()
endfunction

fun! s:Unplace() "{{{
  exe "sign unplace ".s:id
endfunction "}}}

nnoremap <buffer> j j:call <SID>Jump()<cr>
nnoremap <buffer> k k:call <SID>Jump()<cr>
" nnoremap <buffer> <cr> <cr>:syn clear CurrentQFPosition<cr>
nnoremap <buffer> <cr> <cr>:call <SID>Unplace()<cr>




setlocal nobuflisted
