if exists("g:__SETTINGSWITCHER_VIM__")
    finish
endif
let g:__SETTINGSWITCHER_VIM__ = 1

let s:settings = {
            \'fdc':  'foldcolumn',
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
let g:xp_switchers = s:switchers
fun! s:switchers.conceal() "{{{
    if &l:conceallevel == 0
        setlocal conceallevel=2
        setlocal concealcursor=nv
    else
        setlocal conceallevel=0
        setlocal concealcursor=
    endif
endfunction "}}}
let s:switchers.foldcolumn = [0, 3]

fun! s:ShowMenu() "{{{
    let oldcmdheight = &cmdheight

    let pref = ''
    let found = 0
    while ! found

        let matched = []
        for [key, val] in items(s:settings)

            let subkey = strpart(key, 0, len(pref))
            if pref == key
                let found = 1
                break
            endif

            if pref == subkey
                let matched += [[key, val]]
            endif
        endfor

        let &cmdheight = len(matched) + 1
        redraw!

        for [key, val] in matched
            echo '(' . key . ') ' . val
        endfor

        if matched == []
            break
        endif

        let c = nr2char( getchar() )
        let pref .= c
    endwhile

    if ! found
        let &cmdheight = oldcmdheight
        redraw!
        return
    endif

    let c = pref

    if has_key( s:settings, c )
        let setting_key = s:settings[c]

        if has_key(s:switchers, setting_key)

            let swt = s:switchers[setting_key]
            if type(swt) == type([])
                call s:switch_seq(setting_key)
            else
                call swt()
            endif
        else
            exe "setlocal " . s:settings[ c ] . "!"
        endif
    endif

    let &cmdheight = oldcmdheight
    redraw!

endfunction "}}}

fun! s:switch_seq(setting_key) "{{{
    let swt = s:switchers[a:setting_key]
    let [i, len] = [0 - 1, len(swt) - 1]
    while i < len | let i += 1

        exe 'let cur = &l:' . a:setting_key

        if cur == swt[i]
            let nxt = swt[(i + 1) % len(swt)]
            exe 'let &l:' . a:setting_key . ' = ' . nxt
            return
        endif
    endwhile

    exe 'let &l:' . a:setting_key . ' = ' . swt[0]

endfunction "}}}

nnoremap <Plug>view:switchSetting :call <SID>ShowMenu()<CR>



