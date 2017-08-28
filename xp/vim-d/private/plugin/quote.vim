if exists("g:__QUOTE_VIM__")
    finish
endif
let g:__QUOTE_VIM__ = 1

runtime plugin/edit.tinyWord.vim




" --------------------------------- edit.visual -------------------------------- "{{{


xnoremap q<BS>    <esc>`><Right>x`<Xgvhhoh
xnoremap q<CR>    <esc>`>o<Esc>`<O<Esc>gv
xnoremap q<Space> <esc>`>a<Space><esc>`<i<Space><esc>gvlol
xnoremap q.       <esc>`>a.<esc>`<i.<esc>gvlol
xnoremap q+       <esc>`>a+<esc>`<i+<esc>gvlol
xnoremap q`       <esc>`>a`<esc>`<i`<esc>gvlol
xnoremap q=       <esc>`>a=<esc>`<i=<esc>gvlol
xnoremap q$       <esc>`>a$<esc>`<i$<esc>gvlol
xnoremap q*       <esc>`>a*<esc>`<i*<esc>gvlol
xnoremap q<       <esc>`>a><esc>`<i<<esc>gvlol
xnoremap q(       <esc>`>a)<esc>`<i(<esc>gvlol
xnoremap q[       <esc>`>a]<esc>`<i[<esc>gvlol
xnoremap q{       <esc>`>a}<esc>`<i{<esc>gvlol
xnoremap q"       <esc>`>a"<esc>`<i"<esc>gvlol
xnoremap q'       <esc>`>a'<esc>`<i'<esc>gvlol
xnoremap qr       <esc>`>o}<esc>`<O{<esc>gvj=
xnoremap qj       <esc>`>o}<esc>`<kA<space>{<esc>gvj=
xnoremap qm       <esc>`>a */<esc>`<i/* <esc>
xnoremap qif      <esc>`>a)<esc>`<iif (<esc>$

nmap [q<BS>    <Plug>edit:selectWordq<BS>v
nmap [q<CR>    Vq<CR>v
nmap [q<Space> <Plug>edit:selectWordq<Space>v
nmap [q.       <Plug>edit:selectWordq.v
nmap [q+       <Plug>edit:selectWordq+v
nmap [q`       <Plug>edit:selectWordq`v
nmap [q=       <Plug>edit:selectWordq=v
nmap [q$       <Plug>edit:selectWordq$v
nmap [q*       <Plug>edit:selectWordq*v
nmap [q<       <Plug>edit:selectWordq<v
nmap [q(       <Plug>edit:selectWordq(v
nmap [q[       <Plug>edit:selectWordq[v
nmap [q{       <Plug>edit:selectWordq{v
nmap [q"       <Plug>edit:selectWordq"v
nmap [q'       <Plug>edit:selectWordq'v
nmap [qr       <Plug>edit:selectWordqr
nmap [qj       <Plug>edit:selectWordqj
nmap [qm       <Plug>edit:selectWordqm
nmap [qif      <Plug>edit:selectWordqif

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
