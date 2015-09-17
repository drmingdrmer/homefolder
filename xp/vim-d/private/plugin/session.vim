" nmap ,,ws :wa<Bar>exe "mksession! " . v:this_session<CR>

fun! s:SaveSession() "{{{
  if v:this_session != ""
    exe "mksession! " . v:this_session
  endif
endfunction "}}}

augroup Sess
  au!
  au BufWritePost *.* call <SID>SaveSession()
augroup END

