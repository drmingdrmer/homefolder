
nmap <buffer> ,mk :silent! make<CR>:botright cwindow<CR>:redraw!<CR>
" nmap <buffer> ,m :silent! make<CR>:botright cwindow<CR>

nmap <buffer> f[ [[zC[[zO
nmap <buffer> f] [[zC]]zO
nnoremap ,e :cn<CR>
nnoremap ,E :cp<CR>

" align '\' for multi-line c macro
vmap <buffer> <Leader>t\ <C-c>:set lazyredraw<CR>
      \:silent set nohlsearch<CR>
      \:'<,'>s/\s*\\$//<CR>
      \:'<,'>s/$/                                                                                                       \\/<CR>
      \:'<,'>s/\(.\{78}\)\(\s*\)\\/\1\\/<CR>
      \:silent let @/=""<CR>
      \:silent set hlsearch<CR>

nmap <buffer> <Leader>t\ /\\$<CR>?[^\\]$\\|^$<CR><down>V
      \/[^\\]$<CR><up>
      \<Leader>t\

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
