" not finished

fun! s:PreSentence()
  call search("\\S", "b")
  normal $
  if strpart(getline(line(".")), col(".")-1, 1) =~ "}"
    normal %
  endif
  normal ^
endfunction

fun! s:NextSentence()
  normal j
  call search("\\S", "")
  normal $
  if strpart(getline(line(".")), col(".")-1, 1) =~ "{"
    normal %
  endif
  normal ^
endfunction
nmap ( :call <SID>PreSentence()<cr>
nmap ) :call <SID>NextSentence()<cr>
