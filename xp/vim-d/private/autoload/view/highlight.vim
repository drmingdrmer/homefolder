fun! view#highlight#Visual() "{{{
    let oldsearch = @/

    let s = getpos("'<")[1:2]
    let e = getpos("'>")[1:2]

    " exclusive range
    let e[1] = e[1] + 1

    let txt = xpt#util#TextBetween([s, e])

    if '\<' . txt . '\>' ==# oldsearch
        let @/ = txt
    else
        let @/='\<' . txt . '\>'
    endif

    return ''

endfunction "}}}
