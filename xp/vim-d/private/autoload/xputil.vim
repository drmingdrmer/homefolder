fun! xputil#Set(k, ...) "{{{
    if exists('&' . a:k)
        if a:0 == 0
            exe 'set' a:k
        else
            exe 'set' a:k . '=' . a:000[0]
        endif
    endif
endfunction "}}}
