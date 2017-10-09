if exists("g:__QUOTE_VIM__")
    finish
endif
let g:__QUOTE_VIM__ = 1

runtime plugin/edit.tinyWord.vim




" --------------------------------- edit.visual -------------------------------- "{{{


xnoremap ,.<BS>    <esc>`><Right>x`<Xgvhhoh
xnoremap ,.<CR>    <esc>`>o<Esc>`<O<Esc>gv
xnoremap ,.<Space> <esc>`>a<Space><esc>`<i<Space><esc>gvlol
xnoremap ,..       <esc>`>a.<esc>`<i.<esc>gvlol
xnoremap ,.+       <esc>`>a+<esc>`<i+<esc>gvlol
xnoremap ,.`       <esc>`>a`<esc>`<i`<esc>gvlol
xnoremap ,.=       <esc>`>a=<esc>`<i=<esc>gvlol
xnoremap ,.$       <esc>`>a$<esc>`<i$<esc>gvlol
xnoremap ,.*       <esc>`>a*<esc>`<i*<esc>gvlol
xnoremap ,.<       <esc>`>a><esc>`<i<<esc>gvlol
xnoremap ,.(       <esc>`>a)<esc>`<i(<esc>gvlol
xnoremap ,.[       <esc>`>a]<esc>`<i[<esc>gvlol
xnoremap ,.{       <esc>`>a}<esc>`<i{<esc>gvlol
xnoremap ,."       <esc>`>a"<esc>`<i"<esc>gvlol
xnoremap ,.'       <esc>`>a'<esc>`<i'<esc>gvlol
xnoremap ,.r       <esc>`>o}<esc>`<O{<esc>gvj=
xnoremap ,.j       <esc>`>o}<esc>`<kA<space>{<esc>gvj=
xnoremap ,.m       <esc>`>a */<esc>`<i/* <esc>
xnoremap ,.if      <esc>`>a)<esc>`<iif (<esc>$

nmap ,.<BS>    <Plug>edit:selectWord,.<BS>v
nmap ,.<CR>    V,.<CR>v
nmap ,.<Space> <Plug>edit:selectWord,.<Space>v
nmap ,..       <Plug>edit:selectWord,..v
nmap ,.+       <Plug>edit:selectWord,.+v
nmap ,.`       <Plug>edit:selectWord,.`v
nmap ,.=       <Plug>edit:selectWord,.=v
nmap ,.$       <Plug>edit:selectWord,.$v
nmap ,.*       <Plug>edit:selectWord,.*v
nmap ,.<       <Plug>edit:selectWord,.<v
nmap ,.(       <Plug>edit:selectWord,.(v
nmap ,.[       <Plug>edit:selectWord,.[v
nmap ,.{       <Plug>edit:selectWord,.{v
nmap ,."       <Plug>edit:selectWord,."v
nmap ,.'       <Plug>edit:selectWord,.'v
nmap ,.r       <Plug>edit:selectWord,.r
nmap ,.j       <Plug>edit:selectWord,.j
nmap ,.m       <Plug>edit:selectWord,.m
nmap ,.if      <Plug>edit:selectWord,.if

" nnoremap q<Space> <Plug>edit:selectWord<esc>`>a<Space><esc>`<i<Space><esc>
" nnoremap q<       <Plug>edit:selectWord<esc>`>a*<esc>`<i*<esc>
" nnoremap q<       <Plug>edit:selectWord<esc>`>a><esc>`<i<<esc>
" nnoremap q(       <Plug>edit:selectWord<esc>`>a)<esc>`<i(<esc>
" nnoremap q[       <Plug>edit:selectWord<esc>`>a]<esc>`<i[<esc>
" nnoremap q{       <Plug>edit:selectWord<esc>`>a}<esc>`<i{<esc>
" nnoremap qr       <Plug>edit:selectWord<esc>`>o}<esc>`<O{<esc>gvj=
" nnoremap qj       <Plug>edit:selectWord<esc>`>o}<esc>`<kA<space>{<esc>gvj=
" nnoremap q"       <Plug>edit:selectWord<esc>`>a"<esc>`<i"<esc>
" nnoremap q'       <Plug>edit:selectWord<esc>`>a'<esc>`<i'<esc>
" nnoremap qm       <Plug>edit:selectWord<esc>`>a */<esc>`<i/* <esc>
" nnoremap qif      <Plug>edit:selectWord<esc>`>a)<esc>`<iif (<esc>$

" }}}
