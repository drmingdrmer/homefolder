fun! input#GetChar(...) "{{{
    let ptn = ''
    let lst = []

    if a:0 == 0
        let cancel_code = {
              \ 3      : 'c-c',
              \ 27     : 'esc',
              \ "\<BS>": 'backspace',
              \ }
    else
        let cancel_code = a:1
    endif

    echo "type char> "

    let chr_nr = getchar()

    if has_key( cancel_code, chr_nr )
        return ''
    endif

    return nr2char(chr_nr)

endfunction "}}}
