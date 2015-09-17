
nmap <buffer> ,m :silent! make<CR>:botright cwindow<CR>:redraw!<CR>
" nmap <buffer> ,m :silent! make<CR>:botright cwindow<CR>


" switch between c & cpp
fun! s:SwitchC() "{{{
  if &ft != "cpp"
    set ft=cpp
  else
    set ft=c
  endif
endfunction "}}}

nmap <buffer> ,c :silent! call <SID>SwitchC()<CR>

nmap <buffer> f[ [[zC[[zO
nmap <buffer> f] [[zC]]zO
nnoremap ,e :cn<CR>
nnoremap ,E :cp<CR>

" align '\' for multi-line c macro
vmap <buffer> <Leader>t\ <C-c>:set lazyredraw<CR>
      \:set nohlsearch<CR>
      \:'<,'>s/\s*\\$//<CR>
      \:'<,'>s/$/                                                                                                       \\/<CR>
      \:'<,'>s/\([^\\]\{78}\)\(\s*\)\\/\1\\/<CR>
      \:AlignPush<CR>
      \:AlignCtrl p0P0 <CR>
      \gv:Align [^\\]\+<CR>
      \:AlignPop<CR>
      \/<c-v><c-v><CR>
      \:set hlsearch<CR>

nmap <buffer> <Leader>t\ /\\$<CR>?[^\\]$\\|^$<CR><down>V
      \/[^\\]$<CR><up>
      \<Leader>t\

" vmap <buffer> 9t\ :'<,'>s/\\\s*$/\\/<CR>



fun! s:ExtractDec()
  normal! mo
  normal! 0vt="oy
  normal! 0f=b
  normal! hv0d
  normal! [[o"op
  s/\s*$//
  normal! ==A;
  normal! 'o
endfunction

nmap <Leader><Leader>ed :call <SID>ExtractDec()<CR>
