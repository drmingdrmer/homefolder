fun! s:AlignTable() range

    AlignCtrl p0111111111111P1

    '<,'>Align |
    '<,'>s/\s$//

endfunction

vnoremap <buffer> ,at :call <SID>AlignTable()<CR>
nnoremap <buffer> ,at ?^$\n\zs<Bar><CR>V/<Bar>$\n^$<CR>:call <SID>AlignTable()<CR>
