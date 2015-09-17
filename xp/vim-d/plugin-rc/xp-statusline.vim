let g:statusline_max_path = 20
fun! StatusLineGetPath() "{{{
  let p = expand('%:.:h') "relative to current path, and head path only
  let p = substitute(p,'\','/','g')
  let p = substitute(p, '^\V' . escape( $HOME, '\' ), '~', '')
  if len(p) > g:statusline_max_path
    let p = simplify(p)
    let p = pathshorten(p)
  endif
  return p
endfunction "}}}

fun! StatusLineRealSyn() "{{{
    let synId = synID(line('.'),col('.'),1)
    let realSynId = synIDtrans(synId)
    if synId == realSynId
        return 'Normal'
    else
        return synIDattr( realSynId, 'name' )
    endif
endfunction "}}}

fun! MyStatuslineLeft() "{{{
    let sss=""
    let sss.="%#StatuslineBufNr#%-1.2n "                  " buffer number
    let sss.="%h%#StatuslineFlag#%m%r%w"                 " flags
    let sss.="%#StatuslinePath# %-0.20{StatusLineGetPath()}%0*" " path
    let sss.="%#StatuslineFileName#\/%t "                      " file name

    let sss.="%#StatuslineFileEnc# %{&fileencoding} "        " file encoding
    let sss.="%#StatuslineFileType# %{strlen(&ft)?&ft:'**'} ." " filetype
    let sss.="%#StatuslineFileType#%{&fileformat} "            " file format
    let sss.="%#StatuslineTermEnc# %{&termencoding} "          " encoding
    let sss.="%#StatuslineChar# %-2B %0*"                 " current char
    let sss.="%#StatuslineSyn# %{synIDattr(synID(line('.'),col('.'),1),'name')} %0*"           "syntax name
    let sss.="%#StatuslineRealSyn# %{StatusLineRealSyn()} %0*"           "real syntax name

    return sss

endfunction "}}}

fun! MyStatuslineRight() "{{{
    let sss=""
    let sss.="%="
    let sss.="%#StatuslineTime#"
    let sss.=" %-10.(%l,%c-%v%)"             "position
    let sss.="%P"                             "position percentage
    let sss.=" %{strftime(\"%m-%d %H:%M\")}" " current time

    return sss

endfunction "}}}

set statusline=%!MyStatuslineLeft().MyStatuslineRight()
