fun! s:AlignTable() range

    let md_table_align_str = getline(line("'<") + 1)
    let align_str = split(md_table_align_str, '\v\s*[|]\s*', 1)
    let aligns = []
    for aa in align_str
        if aa =~ '\v^:-*:'
            let lr = 'c'
        elseif aa =~ '\v^:'
            let lr = 'l'
        elseif aa =~ '\v:$'
            let lr = 'r'
        else
            let lr = 'l'
        endif
        let aligns += [lr]
    endfor

    let align_control = join(aligns, '')
    echom align_control

    AlignPush
    try
        exec 'AlignCtrl' align_control
        AlignCtrl p0111111111111P1

        '<,'>Align |
        '<,'>s/\s$//
    catch /.*/
        echom v:exception
    finally
        AlignPop
    endtry

endfunction

vnoremap <buffer> ,at :call <SID>AlignTable()<CR>
nnoremap <buffer> ,at ?^$\n\zs<Bar><CR>V/<Bar>$\n^$<CR>:call <SID>AlignTable()<CR>
