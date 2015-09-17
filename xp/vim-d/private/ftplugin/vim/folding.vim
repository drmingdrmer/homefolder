set foldmethod=marker
set foldmarker={{{,}}}
nmap <Leader>fs <C-c>o{{{<esc><C-f>2<up>J
nmap <Leader>fe <C-c>o}}}<esc><C-f>2<up>J
" add folding comments
nmap <Leader><Leader>fl ][<Leader><Leader>fe[[<Leader><Leader>fs
