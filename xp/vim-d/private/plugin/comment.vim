fun! s:InsertComment() "{{{
  if &cms == ""
    return ""
  endif

  let cms = split(substitute(&cms, '\s', '', 'g'), '%s')
  if len(cms) == 1
    let cms += ['']
  endif


  let s =  cms[0] . ' '
  if cms[1] != ''
      let s .= ' ' . cms[1] . repeat("\<Left>", len(cms[1]) + 1)
  endif
  return s

endfunction "}}}

inoremap <expr> <Plug>insert:comment <SID>InsertComment()
