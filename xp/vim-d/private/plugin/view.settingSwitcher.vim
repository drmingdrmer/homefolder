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
            \'x' :  'conceal',
            \}

let s:switchers = {}
fun! s:switchers.conceal() "{{{
    if &l:conceallevel == 0
        setlocal conceallevel=2
        setlocal concealcursor=nv
    else
        setlocal conceallevel=0
        setlocal concealcursor=
    endif
endfunction "}}}
let g:xp_switchers = s:switchers


fun! s:ShowMenu() "{{{
    let oldcmdheight = &cmdheight
    let &cmdheight = len( s:settings ) + 1

    redraw!
    for [key, val] in items(s:settings)
        echo '(' . key . ') ' . val
    endfor
    let c = nr2char( getchar() )

    if has_key( s:settings, c )
        let setting_key = s:settings[c]
        if has_key(s:switchers, setting_key)
            call s:switchers[setting_key]()
        else
            exe "setlocal " . s:settings[ c ] . "!"
        endif
    endif

    let &cmdheight = oldcmdheight
    redraw!

endfunction "}}}

nnoremap <Plug>view:switchSetting :call <SID>ShowMenu()<CR>



