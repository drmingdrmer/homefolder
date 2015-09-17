"correct Module path according to fild path

fun! s:FindModDec()
  call search('\(new\s*Module\s*(\s*"\)\@<=')
endfunction

fun! s:FindModDecEnd()
  call search('.\("\)\@=')
endfunction

fun! s:SelectModDec()
  call s:FindModDec()
  normal v
  call s:FindModDecEnd()
endfunction

fun! s:GetModuleDec()
  call StoreCursor()
  call StoreReg()

  call s:SelectModDec()
  normal y
  let dec = @@

  call BackToLastCursor()
  call RestoreReg()

  return dec
endfunction

fun! s:CorrectCurFile()
  let curfn = expand("%:p")
  let dec = s:GetModuleDec()
  let path = b:GetCurNameByPath()
  " echo dec." ".path

  if dec != path
    if confirm("not correct ", "&move\n&change name") == 1
      " move
      let tarPath = substitute(dec, '\.', '/', 'g').'.module.js'
      let mr = match(expand("%:p"), b:module_root_end)
      let tarPath = strpart(expand("%:p"), 0, mr).tarPath
      let tarFolder = strpart(tarPath, 0, strridx(tarPath, '/'))

      
      silent! call mkdir(tarFolder)
      exe "bw ".bufnr("%")
      call rename(curfn, tarPath)
      exe "edit ".tarPath
      
    else
      " change
      call StoreCursor()
      call StoreReg()
      
      call s:FindModDec()
      exe '.s/'.dec.'/'.path.'/'

      call BackToLastCursor()
      call RestoreReg()
    endif

  endif

endfunction
com! -bar XXmck call <SID>CorrectCurFile()

" au BufWinEnter *.module.js XXmck


