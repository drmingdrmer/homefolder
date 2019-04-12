
fun! HighLightColor(clr)
    if !exists("b:__syn_colors__")
        let b:__syn_colors__ = {}
    endif

    let clr = a:clr

    if clr !~ '\x\{6}'
        " echom "not a color : " . clr
        return
    endif

    let clr = matchstr( clr, '\x\{6}' )

    " echom "to match color:" . clr

    if has_key( b:__syn_colors__, clr )
        return
    endif


    if clr =~ '^[0-7]'
        let fg = 'white'
    else
        let fg = 'black'
    endif
    exe 'hi XPS_' . clr . ' guifg=' . fg . ' guibg=#' . clr
    call matchadd('XPS_' . clr, clr, 5)

    let b:__syn_colors__[ clr ] = 1


endfunction

fun! XXFade( from, to, n ) abort "{{{

    let n = a:n

    let from = matchstr( a:from, '[^#]\+' )
    let to = matchstr( a:to, '[^#]\+' )

    let fs = split( from, '..\zs' )
    let ts = split( to, '..\zs' )
    echo string(fs)
    echo string(ts)

    call map( fs, 'eval("0x" . v:val)' )
    call map( ts, 'eval("0x" . v:val)' )

    let hsvFrom = hiemp#RGB_HSV( fs[0], fs[1], fs[2] )
    let hsvTo   = hiemp#RGB_HSV( ts[0], ts[1], ts[2] )

    let step = [ hsvTo[0] - hsvFrom[0], hsvTo[1] - hsvFrom[1], hsvTo[2] - hsvFrom[2] ]
    call map( step, 'v:val / ' . n )

    let v = a:from
    let n -= 1

    let rst = [v]
    while n > 1

        let hsvFrom[0] += step[0]
        let hsvFrom[1] += step[1]
        let hsvFrom[2] += step[2]
        let rgb = hiemp#HSV_RGB( hsvFrom[0], hsvFrom[1], hsvFrom[2] )
        let v = '#' . printf( '%02x%02x%02x', rgb[0], rgb[1], rgb[2] )

        call add(rst, v)

        let n = n - 1
    endwhile

    let v = a:to
    call add(rst, v)
    return rst

endfunction "}}}

fun! XXTo() range

    let s = getpos("'<")[1]
    let e = getpos("'>")[1]

    let c1 = trim(getline(s))
    let c2 = trim(getline(e))

    let ff = XXFade(c1, c2, e-s+1)

    normal gvd
    call append(s-1, ff)

endfunction


augroup XPCCColor
    au!
    au CursorMoved,CursorMovedI <buffer> call HighLightColor(expand( "<cword>" ))
augroup END
