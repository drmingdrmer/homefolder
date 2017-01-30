" xnoremap <buffer> ,at :call markdown#AlignTableVisual()<CR>
" nnoremap <buffer> ,at :call markdown#SelectTableUnderCursor()<CR>:call markdown#AlignTableVisual()<CR>

" xnoremap <buffer> ,tac :call markdown#AddColumnVisual()<CR>
" nnoremap <buffer> ,tac :call markdown#SelectTableUnderCursor()<CR>:call markdown#AddColumnVisual()<CR>

fun! s:RemoveDuplicateLatexWikipedia() "{{{

    " {\displaystyle ... } is duplicate to the following part.

    while 1
        let pos = searchpos('\V{\\displaystyle\>', 'c')
        echom string(pos)
        if pos == [0, 0]
            break
        endif
        s/\V{\\displaystyle\(\.\{-}\)} \*\1/$ \1 $
    endwhile

endfunction "}}}

com! XXcleanwiki call <SID>RemoveDuplicateLatexWikipedia()
