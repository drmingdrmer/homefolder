let b:SuperTabDefaultCompletionType = '<c-p>'

" help "gf" to open a file
setlocal suffixesadd+=.md,.markdown

" wrap text display, because a doc have long sentences.
setlocal wrap

" convert math from wikipedia to latex in markdown
nnoremap <buffer> <Leader><Leader>wk :%s/\V{\\displaystyle \(\.\*\)}\$/$$\r\1\r$$/<CR>

" " remove images after copying content from one-tab
" nnoremap <buffer> <Leader><Leader>im :%s/\V![img](\.\{-\})//<CR>

" convert one-tabe "url | title" into markdown style
nnoremap <buffer> <Leader><Leader>lk :%s/\(.\{-\}\) <Bar> \(.*\)/[\2](\1)/<CR>
