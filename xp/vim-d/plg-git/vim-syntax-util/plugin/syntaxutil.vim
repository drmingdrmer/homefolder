fun! CurSyntaxName() " {{{
  let synId = synID(line("."), col("."), 1)
  let synName = synIDattr(synId, "name")
  return synName
endfunction " }}}
fun! SyntaxName(l, c) " {{{
  let synId = synID(a:l, a:c, 1)
  let synName = synIDattr(synId, "name")
  return synName
endfunction " }}}
fun! FiletypeFromSyn(synName) " {{{
  " deal with special name
  let snm = a:synName
  if snm =~ '^\(javaScript\|__\)'
    " make the first upper case char to lower case
    let snm = substitute(snm, '\u', '\l\0', "")
  endif
  let snm = substitute(snm, '\u.*', '', '')
  return snm
endfunction " }}}

fun! CurFiletype() " {{{
  return FiletypeFromSyn(CurSyntaxName())
endfunction " }}}
fun! CurLineFiletype() " {{{
  return FiletypeFromSyn(SyntaxName(line('.'), col("$")-1))
endfunction " }}}

fun! SynNameStack(l, c) "{{{
  let ids = synstack(a:l, a:c)
  if empty(ids)
    return []
  endif

  let names = []
  for id in ids 
    let names = names + [synIDattr(id, "name")]
  endfor
  return names
endfunction "}}}

fun! CurSynNameStack() "{{{
  return SynNameStack(line("."), col("."))
endfunction "}}}

