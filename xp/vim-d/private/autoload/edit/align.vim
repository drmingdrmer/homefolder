fun! edit#align#VerticalDeleteToWordStart() "{{{
    let c = getpos("'<")[2]
    exe 's/\%>' . c . 'c */'
    call cursor(getpos("'<")[1:2])
endfunction "}}}
