fun! s:goto_c_h() "{{{

    let fn = expand('%')

    let csuffix = '.c'
    if &filetype == 'cpp'
        let csuffix = '.cpp'
    endif

    let tofn = ''
    if fn =~ '\V.h\$'
        let tofn = substitute(fn, '\V.h\$', '.c', '')
        if ! filereadable(tofn)
            let tofn .= 'pp'
        endif
    elseif fn =~ '\V' . csuffix . '\$'
        let tofn = substitute(fn, '\V.\w\+\$', '.h', '')
    endif

    if tofn != ''
        return ':edit ' . tofn . "\<CR>"
    else
        return ''
    endif
endfunction "}}}

noremap <buffer><expr> <Leader>ga <SID>goto_c_h()
