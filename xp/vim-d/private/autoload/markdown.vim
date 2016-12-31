fun! markdown#SelectTableUnderCursor() "{{{

    " search table start, a "|" after blank line
    call searchpos('\v^$\n\zs\|', 'bc')

    normal V

    " search table end, a "|" before blank line
    call searchpos('\v\|$\n^$')
endfunction "}}}

fun! markdown#AddColumnVisual() range "{{{
    '<s/$/ header |/
    '<+1s/$/ :--    |/
    '<+2,'>s/$/        |/
endfunction "}}}

fun! markdown#AlignTableVisual() range "{{{

    let md_table_align_str = getline(line("'<") + 1)

    " extract alignment from table: :--, :-:, or --:
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
    " echom align_control

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
