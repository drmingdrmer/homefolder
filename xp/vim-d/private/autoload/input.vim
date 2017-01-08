fun! input#GetChar(prompt, ...) "{{{
    let ptn = ''
    let lst = []

    if a:0 == 0
        " \ "\<BS>": 'backspace',
        let cancel_code = {
              \ 3      : 'c-c',
              \ 27     : 'esc',
              \ }

    else
        let cancel_code = a:1
    endif

    if a:prompt != ''
        echo a:prompt
    endif

    let chr_nr = getchar()

    if has_key( cancel_code, chr_nr )
        return ''
    endif

    return nr2char(chr_nr)

endfunction "}}}
