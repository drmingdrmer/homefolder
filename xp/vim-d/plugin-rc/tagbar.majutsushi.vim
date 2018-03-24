let g:tagbar_type_markdown = {
            \ 'ctagstype' : 'markdown',
            \ 'kinds' : [
                \ 'h:headings',
                \ 'l:links',
                \ 'i:images'
            \ ],
    \ "sort" : 0
\ }

" when using "x" to zoom tagbar, use the max visible tag width
let g:tagbar_zoomwidth = 0

nmap <M-8> :TagbarToggle<CR>
