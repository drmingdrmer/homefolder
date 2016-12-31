xnoremap <buffer> ,at :call markdown#AlignTableVisual()<CR>
nnoremap <buffer> ,at :call markdown#SelectTableUnderCursor()<CR>:call markdown#AlignTableVisual()<CR>

xnoremap <buffer> ,ac :call markdown#AddColumnVisual()<CR>
nnoremap <buffer> ,ac :call markdown#SelectTableUnderCursor()<CR>:call markdown#AddColumnVisual()<CR>
