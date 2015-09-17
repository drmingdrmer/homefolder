if exists( "g:__XP__PLUGIN__TAB_CONFIG_VIM__" )
    finish
endif
let g:__XP__PLUGIN__TAB_CONFIG_VIM__ = 1

function! MyTabLabel(n)
  let buflist = tabpagebuflist(a:n)
  let winnr = tabpagewinnr(a:n)
  let bn =  bufname(buflist[winnr - 1])
  let bn = substitute(bn, ".*/", '', 'g')
  if bn == ''
    let bn = "*"
  endif
  return bn
endfunction
function! MyTabLine()
  let s = ''
  for i in range(tabpagenr('$'))
    " select the highlighting
    if i + 1 == tabpagenr()
      let s .= '%#TabLineSel#'
    else
      let s .= '%#TabLine#'
    endif

    " set the tab page number (for mouse clicks)
    let s .= '%' . (i + 1) . 'T'

    " the label is made by MyTabLabel()
    let s .= ' %{MyTabLabel(' . (i + 1) . ')} '
  endfor

  " after the last tab fill with TabLineFill and reset tab page nr
  let s .= '%#TabLineFill#%T'

  " right-align the label to close the current tab page
  if tabpagenr('$') > 1
    let s .= '%=%#TabLine#%999Xclose'
  endif

  return s
endfunction
set tabline=%!MyTabLine()



fun! s:MoveTab(t) "{{{
  let n = tabpagenr()  -1 + a:t
  if n < 0 
    let n = 0
  endif
  echo n
  exe "tabmove ".(n)
endfunction "}}}

nmap <unique> <Plug>nav:tab_move_forward  :call <SID>MoveTab(1)<cr>
nmap <unique> <Plug>nav:tab_move_backword :call <SID>MoveTab(-1)<cr>

nmap <unique> <Plug>nav:tab_next :tabn<cr>
nmap <unique> <Plug>nav:tab_prev :tabp<cr>


