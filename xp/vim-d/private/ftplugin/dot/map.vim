nnoremap <buffer> ,cnv :!dot <C-r>% -Tpng -o <C-r>%.png<cr>
" to view
" TODO refine me
nmap <buffer> ,vv ,cnv:echo system("gnome-open <C-r>%.png")<cr>
nmap <buffer> ,g :echo system("gnome-open <C-r>%.png")<cr>

" style
inoreabbr <buffer> td style = dashed
inoreabbr <buffer> se shape = ellipse
inoreabbr <buffer> sp shape = point
inoreabbr <buffer> sb shape = box
inoreabbr <buffer> cb color = black
inoreabbr <buffer> ai arrowhead = inv
inoreabbr <buffer> an arrowhead = none
inoreabbr <buffer> w0 weight = 0.01
inoreabbr <buffer> rs rank = same
inoreabbr <buffer> lb label = ""<Left>




