fun! markdown#SelectTableUnderCursor() "{{{

    " search table start, a "|" after blank line
    call searchpos('\v^$\n\zs\|', 'bc')

    normal V

    " search table end, a "|" before blank line
    call searchpos('\v\|$\n^$')
endfunction "}}}
