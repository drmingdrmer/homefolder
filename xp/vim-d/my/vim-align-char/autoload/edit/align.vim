fun! edit#align#VerticalDeleteToWordStart() "{{{
    let vcol = virtcol("'<")
    exe 's/\%>' . (vcol-1) . 'v */'
    call cursor(getpos("'<")[1:2])
endfunction "}}}

hi def link FooGotoCandidate Visual

fun! edit#align#VerticalAlign(regex, range, vcol) "{{{

    let save_cursor = getpos('.')[1:2]
    let [line_start, line_end] = a:range
    let vcol       = a:vcol

    if a:regex == ''
        let regex_before = edit#align#InteractiveInputRegex(line_start, line_end)
        if regex_before == ''
            return
        endif
    else
        let regex_before = a:regex
    endif

    " find max virtical col

    let maxvcol = vcol
    let i = line_start
    while i <= line_end
        let ptn = '\V\%' . i . 'l\%>' . (vcol-1) . 'v \*' . regex_before

        let pos = searchpos(ptn, 'c')
        if pos[0] == 0
            let i += 1
            continue
        endif

        if maxvcol < virtcol(pos)
            let maxvcol = virtcol(pos)
        endif

        let i += 1
    endwhile

    " add space to align

    let i = line_start
    while i <= line_end
        let ptn = '\V\%' . i . 'l\%>' . (vcol-1) . 'v \*\ze' . regex_before

        let pos = searchpos(ptn, 'c')
        if pos[0] == 0
            let i += 1
            continue
        endif

        " leave another space before regex_before
        exec 's/' . ptn . '/' . repeat(' ', maxvcol - virtcol(pos) + 1) . '/'

        let i += 1
    endwhile

    call cursor(save_cursor)

endfunction "}}}

fun! edit#align#VerticalAlignVisual(regex) range "{{{

    call edit#align#VerticalAlign(a:regex, [a:firstline, a:lastline], virtcol("'<"))

    call cursor(getpos("'<")[1:2])

endfunction "}}}

fun! edit#align#InteractiveInputRegex(line_start, line_end) "{{{

    let ptn = ''
    let lst = []
    let cancel_code = {
          \ 3: 'c-c',
          \ 27: 'esc',
          \ }
    let b:search_match_id = 0

    while 1

        echo "regex>" . join( lst, '' )
        let chr_nr = getchar()

        call s:clearMatch()

        " cr
        if chr_nr == 13 && len(lst) > 0
            call s:clearMatch()
            return join(lst, '')
        end

        if has_key( cancel_code, chr_nr )
            call s:clearMatch()
            return ''
        endif


        if chr_nr == "\<BS>"
            if len(lst) > 0
                call remove(lst, -1)
            endif

        else
            let chr = nr2char(chr_nr)
            call add( lst, chr )
        end

        let vcol = virtcol("'<")

        let ptn  = '\V\%>' . (a:line_start-1) . 'l'
        let ptn .=   '\%<' . (a:line_end+1) . 'l'
        let ptn .=   '\%>' . (vcol-1) . 'v' . join(lst, '')

        let b:search_match_id = matchadd( 'FooGotoCandidate', ptn )

        redraw!

    endwhile
endfunction "}}}

fun! edit#align#FindParagraph() "{{{

    let cur_ln = getpos(".")[1]
    let cur_indent = indent(".")

    let start_ln = cur_ln

    while start_ln >= 1 && indent(start_ln) == cur_indent && getline(start_ln) !~ '\v^\s*$'
        let start_ln -= 1
    endwhile

    let start_ln += 1

    let end_ln = cur_ln

    while indent(end_ln) == cur_indent && getline(end_ln) !~ '\v^\s*$'
        let end_ln += 1
    endwhile

    let end_ln -= 1

    return [start_ln, end_ln]

endfunction "}}}

fun! edit#align#n() "{{{
    
endfunction "}}}

fun! s:clearMatch() "{{{
    if exists('b:search_match_id')
        if b:search_match_id != 0
            call matchdelete(b:search_match_id)
            let b:search_match_id = 0
        end
    endif
endfunction "}}}
