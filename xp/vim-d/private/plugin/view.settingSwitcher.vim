if exists("g:__SETTINGSWITCHER_VIM__")
    finish
endif
let g:__SETTINGSWITCHER_VIM__ = 1

let s:settings = {
            \'l' :  'list',
            \'p' :  'spell',
            \'n' :  'number',
            \'r' :  'wrap',
            \'u' :  'cursorline',
            \'c' :  'cursorcolumn',
            \'m' :  'modifiable',
            \}


fun! s:ShowMenu() "{{{
    let oldcmdheight = &cmdheight
    let &cmdheight = len( s:settings ) + 1

    redraw!
    for [key, val] in items(s:settings)
        echo '(' . key . ') ' . val
    endfor
    let c = nr2char( getchar() )

    if has_key( s:settings, c )
        exe "setlocal " . s:settings[ c ] . "!"
    endif

    let &cmdheight = oldcmdheight
    redraw!

endfunction "}}}

nnoremap <Plug>view:switchSetting :call <SID>ShowMenu()<CR>



