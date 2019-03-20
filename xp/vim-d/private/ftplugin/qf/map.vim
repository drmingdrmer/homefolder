" When use j/k in quickfix window it move main buffer to where the line indicates.

hi CurrentQFPosition cterm=none ctermbg=green 

sign define curPos text=>> linehl=MarkWord1


fun! QuickFixPlaceSign()

  if !exists("b:quickfixSignID")
    let b:quickfixSignID = 1
  endif

  " remove previous
  call QuickFixRemoveSign()

  let b:quickfixSignID = 3 - b:quickfixSignID

  let ln = line(".")
  exe 'sign place ' . b:quickfixSignID . ' line=' . ln . ' name=curPos buffer=' . winbufnr(0)
endfun

fun! QuickFixRemoveSign()
  if !exists("b:quickfixSignID")
    let b:quickfixSignID = 1
  endif
  silent! exe 'sign unplace ' . b:quickfixSignID . ' buffer=' . winbufnr(0)
endfun

nnoremap <buffer> j j<CR>zR:call QuickFixPlaceSign()<CR><C-w><C-p>
nnoremap <buffer> k k<CR>zR:call QuickFixPlaceSign()<CR><C-w><C-p>
nnoremap <buffer> <CR> <CR>:call QuickFixRemoveSign()<CR>
