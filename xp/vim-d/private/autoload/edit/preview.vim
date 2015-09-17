fun! edit#preview#Open() "{{{

    pedit
    wincmd P
    wincmd L
    set winfixwidth

    if &tw == 0
        let width = 80
    else
        let width = &tw
    endif

    let width += 5

    exe 'vertical resize' width
    return ''

endfunction "}}}
