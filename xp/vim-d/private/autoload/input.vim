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

    " special key is not a number, see :h getchar()
    if type(chr_nr) == type('')
        return chr_nr
    else
        return nr2char(chr_nr)
    endif

endfunction "}}}
