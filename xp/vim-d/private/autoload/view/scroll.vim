fun! view#scroll#IgnoreBinding(dir) "{{{
    let s = &scrollbind
    let &scrollbind = 0

    let v = "\<C-y>"

    if a:dir == 'u'
        let v = "\<C-y>"
    else
        let v = "\<C-e>"
    endif

    exe "normal!" v

    let &scrollbind = s


endfunction "}}}

