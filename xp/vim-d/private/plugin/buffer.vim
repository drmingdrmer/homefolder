" buffer nagivation

set hidden
set tags=tags

fun! s:def(k, v) "{{{
    if !exists( a:k )
        exe "let" a:k "=" string( a:v )
    endif
endfunction "}}}

call s:def( 'g:xp_buf_close', [] )
let s:buf_close = [
      \ '\V/.git/COMMIT_EDITMSG\$',
      \ ]


fun! s:RmBuf()

  if &previewwindow
    " just close previewwindow
    pclose

    call s:toNextNormalBuf()
    return
  endif

  let buftype = &buftype
  let bufhidden = &bufhidden
  let bn = bufnr("%")
  let lastbn = bufnr( "$" )
  let bufname = bufname( bn )

  if lastbn == bn
      bprev
  else
      bnext
  endif

  " sometimes buf will be removed automatically by plugins when switching
  try
    exe "bw ".bn
  catch /.*/
  endtry

  if buftype != "" || bufhidden =~ '\vunload|delete|wipe'
      exec "close"
      return
  endif

  let foo = s:close_by_patterns( bufname, g:xp_buf_close )
        \ || s:close_by_patterns( bufname, s:buf_close )

endfunction

fun! s:close_by_patterns( bufname, ptns ) "{{{

  for close_reg in a:ptns
    if a:bufname =~# close_reg
      exec 'close'
      return 1
    endif
  endfor

  return 0
endfunction "}}}

fun! s:toNextNormalBuf() "{{{
  while winnr() < winnr("$") && &buftype != ""
    wincmd w
  endwhile
endfunction "}}}

fun! s:ToBuf(i)
  let i = a:i
  let bi = 0
  let be = bufnr("$")
  while (i>0 && bi<be)
    let bi = bi + 1
    if buflisted(bi)
      let i = i - 1
    endif
  endwhile
  exe "b".bi
endfunction

fun! s:RmNoNamed()
  let i = 1
  let e = bufnr("$")
  while i <= e
    if bufexists(i) && bufname(i) == ""
      exe i."bw"
    endif

    let i += 1
  endwhile
endfunction

noremap <Plug>buffer:rm_nonamed :call <SID>RmNoNamed()<cr>
nmap <Leader><Leader>rm <Plug>buffer:rm_nonamed

fun! s:UpdateTag()
  let cwd = getcwd()
  let tag = cwd . '/tags'

  let file = expand("%")

  if file =~ "^/"
    return
  endif

  if filereadable(tag) && executable("ctags")
    exe 'silent! :!ctags --append=yes "'.file.'"'
  endif
endfunction




fun! s:UpDiff() "{{{
    if &diff
        silent diffupdate
    endif
endfunction "}}}

augroup DiffUpdate
    au!
    au BufWritePost,CursorHold,CursorHoldI * call s:UpDiff()
augroup END


augroup Tag
  au!
  au BufWritePost * call <SID>UpdateTag()
augro END

augroup VIM_FOLDER_AUTO
    au!
augroup END

nmap <F12> <PLug>buffer:quit_all
nnoremap <Plug>buffer:quit_all :qa!<cr>
nnoremap <Plug>buffer:createTags    :silent! !ctags -R *<CR>:redraw!<CR>
nnoremap <Plug>buffer:make_executable :silent !chmod +x %<CR>:redraw!<CR>

fun! s:TryToMakeExcutable() "{{{
    if &buftype == ''
        if getline( 1 ) =~ '\V\^#!/'
            silent! !chmod +x %
        endif
    endif
endfunction "}}}

augroup Excutable
    au!
    au BufNew,BufNewFile,BufRead,BufEnter *.sh call s:TryToMakeExcutable()
augroup END

"map{{{
nnoremap <Plug>buffer:writeAndQuit      :w<cr>:q<cr>
nnoremap <Plug>buffer:prev              :bprev<cr>
nnoremap <Plug>buffer:next              :bnext<cr>
nnoremap <Plug>buffer:rm_buf_close      :silent! call <SID>RmBuf()<cr>
nnoremap <Plug>buffer:rm_buf_only       <esc>:silent! call <SID>RmBuf()<cr>
nnoremap <Plug>buffer:rm_buf_win        <esc>:silent! call <SID>RmBuf()<cr><C-w>c
nnoremap <Plug>buffer:to1               :call <SID>ToBuf(1)<cr>
nnoremap <Plug>buffer:to2               :call <SID>ToBuf(2)<cr>
nnoremap <Plug>buffer:to3               :call <SID>ToBuf(3)<cr>
nnoremap <Plug>buffer:to4               :call <SID>ToBuf(4)<cr>
nnoremap <Plug>buffer:to5               :call <SID>ToBuf(5)<cr>
nnoremap <Plug>buffer:to6               :call <SID>ToBuf(6)<cr>
nnoremap <Plug>buffer:to7               :call <SID>ToBuf(7)<cr>
nnoremap <Plug>buffer:to8               :call <SID>ToBuf(8)<cr>
nnoremap <Plug>buffer:to9               :call <SID>ToBuf(9)<cr>
nnoremap <Plug>buffer:to0               :call <SID>ToBuf(10)<cr>
" show tag in preview window; go to preview window; make it right most
nnoremap <Plug>buffer:tag_in_preview_right    <C-w>}<C-w>P<C-w>L:set winfixwidth<CR>:exe 'vertical resize' (!!&tw)*&tw+(!&tw)*80<CR>
nnoremap <Plug>buffer:tag_in_preview_top      <C-w>}
"map}}}

" vim: shiftwidth=2
