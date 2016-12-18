fun! edit#align#VerticalDeleteToWordStart() "{{{
    let c = virtcol("'<")
    exe 's/\%>' . c . 'v */'
    call cursor(getpos("'<")[1:2])
endfunction "}}}
