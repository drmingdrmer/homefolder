finish






let s:callback=[[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[]]

fun! s:SID() "{{{
  return matchstr(expand('<sfile>'), '<SNR>\d\+_\zeSID$')
endfunction "}}}

fun! AddSuperTabCB(n, cb) "{{{
  " if get(s:callback, a:n) == 0
    " let s:callback[a:n] = []
  " endif
  call add(s:callback[a:n], a:cb)
endfunction "}}}

fun! s:SuperTab() "{{{

  for v in s:callback
    for tb in v
      let t = eval(tb."()")
      if t != ""
        return t
      endif
    endfor
  endfor

  " default:
  return "\<tab>"
endfunction "}}}

" iunmap <tab>
imap <tab> <C-r>=<SID>SuperTab()<cr>



" function
" funcate

fun! s:TagCompl() "{{{
  if pumvisible()
    return "\<C-y>\<C-n>"
  endif
  return "\<c-n>"
endfunction "}}}
call AddSuperTabCB(10,  s:SID()."TagCompl" )
