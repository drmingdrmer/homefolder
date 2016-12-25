fun! edit#align#VerticalDeleteToWordStart() "{{{
    let vcol = virtcol("'<")
    exe 's/\%>' . (vcol-1) . 'v */'
    call cursor(getpos("'<")[1:2])
endfunction "}}}
