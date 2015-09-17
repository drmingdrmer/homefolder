fun! s:AlignMultiLinesDict() "{{{
    AlignPush
    AlignCtrl p01P11
    AlignCtrl ll:
    '<,'>Align \\\|:
    AlignPop
endfunction "}}}

vnoremap <buffer> ,d <ESC>:call <SID>AlignMultiLinesDict()<CR>

nnoremap <buffer> ,d ?\v^\s*[^\\ ]<CR><DOWN>v/\v^\s*[^\\ ]\|^\s*\\\s*}$<CR><UP><ESC>:let @/=""<CR>:call <SID>AlignMultiLinesDict()<CR>





