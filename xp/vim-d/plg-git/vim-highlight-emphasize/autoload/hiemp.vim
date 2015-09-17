if exists("g:__highlight_emphasize_8fsy8fds__")
    finish
endif
let g:__highlight_emphasize_8fsy8fds__ = 1

fun! hiemp#RGB_HSV(red, green, blue) "{{{
    let max = a:red > a:green ? a:red : a:green
    let max = max > a:blue ? max : a:blue
    let min = a:red < a:green ? a:red : a:green
    let min = min < a:blue ? min : a:blue
    let value = max
    let d = max - min
    if d > 0
        let saturation = 255*d/max
        if a:red == max
            let hue = 60*(a:green - a:blue)/d
        elseif a:green == max
            let hue = 120 + 60*(a:blue - a:red)/d
        else
            let hue = 240 + 60*(a:red - a:green)/d
        endif
        let hue = (hue + 360) % 360
    else
        let saturation = 0
        let hue = 0
    endif

    return [ hue, saturation, value ]
endfun "}}}

fun! hiemp#HSV_RGB(hue, saturation, value) "{{{
    let red   = hiemp#HSV_R(a:hue, a:saturation, a:value)
    let green = hiemp#HSV_G(a:hue, a:saturation, a:value)
    let blue  = hiemp#HSV_B(a:hue, a:saturation, a:value)
    return [ red, green, blue ]
endfun "}}}

fun! hiemp#HSV_R(h, s, v) "{{{
    if a:s == 0
        return a:v
    endif
    let f = a:h % 60
    let i = a:h/60
    if i == 0 || i == 5
        return a:v
    elseif i == 2 || i == 3
        return a:v*(255 - a:s)/255
    elseif i == 1
        return a:v*(255*60 - (a:s*f))/60/255
    else
        return a:v*(255*60 - a:s*(60 - f))/60/255
    endif
endfun "}}}

fun! hiemp#HSV_G(h, s, v) "{{{
    if a:s == 0
        return a:v
    endif
    let f = a:h % 60
    let i = a:h/60
    if i == 1 || i == 2
        return a:v
    elseif i == 4 || i == 5
        return a:v*(255 - a:s)/255
    elseif i == 3
        return a:v*(255*60 - (a:s*f))/60/255
    else
        return a:v*(255*60 - a:s*(60 - f))/60/255
    endif
endfun "}}}

fun! hiemp#HSV_B(h, s, v) "{{{
    if a:s == 0
        return a:v
    endif
    let f = a:h % 60
    let i = a:h/60
    if i == 3 || i == 4
        return a:v
    elseif i == 0 || i == 1
        return a:v*(255 - a:s)/255
    elseif i == 5
        return a:v*(255*60 - (a:s*f))/60/255
    else
        return a:v*(255*60 - a:s*(60 - f))/60/255
    endif
endfun "}}}

fun! hiemp#Fade( from, to, key, ... ) "{{{

    let from = matchstr( a:from, '[^#]\+' )
    let to = matchstr( a:to, '[^#]\+' )

    let fs = split( from, '..\zs' )
    let ts = split( to, '..\zs' )

    " this is comment

    call map( fs, 'eval("0x" . v:val)' )
    call map( ts, 'eval("0x" . v:val)' )

    let hsvFrom = hiemp#RGB_HSV( fs[0], fs[1], fs[2] )
    let hsvTo   = hiemp#RGB_HSV( ts[0], ts[1], ts[2] )

    let nStep = len( a:000 ) - 1

    let step = [ hsvTo[0] - hsvFrom[0], hsvTo[1] - hsvFrom[1], hsvTo[2] - hsvFrom[2] ]
    call map( step, 'v:val / ' . nStep )

    for name in a:000
        let rgb = hiemp#HSV_RGB( hsvFrom[0], hsvFrom[1], hsvFrom[2] )
        let cmd = 'hi ' . name . ' ' . a:key . '=#' . printf( '%02x%02x%02x', rgb[0], rgb[1], rgb[2] )

        let hsvFrom[0] += step[0]
        let hsvFrom[1] += step[1]
        let hsvFrom[2] += step[2]

        exe cmd
    endfor

endfunction "}}}

fun! hiemp#RGBlist(rgb) "{{{
    let str = matchstr( a:rgb, '[^#]\+' )
    let list = split( str, '..\zs' )
    call map( list, 'eval("0x" . v:val)' )

    return list
endfunction "}}}

fun! hiemp#EmphasizeColor(rgb, percent) "{{{
    let list = hiemp#RGBlist(a:rgb)
    let list[0] += list[0] * a:percent / 100
    let list[1] += list[1] * a:percent / 100
    let list[2] += list[2] * a:percent / 100

    return (a:rgb[0:0] == '#' ? '#' : '' ) . printf( '%02x%02x%02x', list[0], list[1], list[2] )
endfunction "}}}

fun! hiemp#EmphasizeHLs(percent, hls ) "{{{
    for hlname in a:hls
        try
            let fg = synIDattr(synIDtrans(hlID(hlname)), 'fg#', 'gui')
            let bg = synIDattr(synIDtrans(hlID(hlname)), 'bg#', 'gui')


            if fg == '' || fg == '-1'
                let fg = 'NONE'
            else
                let fg = hiemp#EmphasizeColor(fg, a:percent)
            endif

            if bg == '' || bg == '-1'
                let bg = 'NONE'
            else
                " let bg = hiemp#EmphasizeColor(bg, a:percent)
            endif

            exe 'hi ' . hlname . 'Emphasize guifg=' . fg . ' guibg=' . bg
        catch
            echom 'failed to emphasize:' . string([hlname, fg, bg])
            exe 'hi ' . hlname
        endtry
    endfor
endfunction "}}}
