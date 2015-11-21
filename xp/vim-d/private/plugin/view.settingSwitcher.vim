if exists("g:__SETTINGSWITCHER_VIM__")
    finish
endif
let g:__SETTINGSWITCHER_VIM__ = 1

let s:settings = {
            \'.fc':  'foldcolumn',
            \'.c' :  'clean',
            \
            \'l' :  'list',
            \'p' :  'spell',
            \'n' :  'number',
            \'r' :  'wrap',
            \'cl' :  'cursorline',
            \'cc' :  'cursorcolumn',
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
fun! s:switchers.clean() "{{{
    if &showtabline == 0
        set showtabline=2
        set laststatus=2
        set cmdheight=2
        call system('tmux set status on >/dev/null 2>/dev/null')
    else
        set showtabline=0
        set laststatus=0
        set cmdheight=1
        call system('tmux set status off >/dev/null 2>/dev/null')
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

    let &cmdheight = oldcmdheight
    redraw!

    if ! found
        return
    endif

    let c = pref

    if has_key( s:settings, c )
        let setting_key = s:settings[c]

        if has_key(s:switchers, setting_key)

            if type(s:switchers[setting_key]) == type([])
                call s:switch_seq(setting_key)
            else
                call s:switchers[setting_key]()
            endif
        else
            exe "setlocal " . s:settings[ c ] . "!"
        endif
    endif

    redraw!

endfunction "}}}

fun! s:switch_seq(setting_key) "{{{
    let Swt = s:switchers[a:setting_key]
    let [i, len] = [0 - 1, len(Swt) - 1]
    while i < len | let i += 1

        exe 'let cur = &l:' . a:setting_key

        if cur == Swt[i]
            let nxt = Swt[(i + 1) % len(Swt)]
            exe 'let &l:' . a:setting_key . ' = ' . nxt
            return
        endif
    endwhile

    exe 'let &l:' . a:setting_key . ' = ' . Swt[0]

endfunction "}}}

nnoremap <Plug>view:switchSetting :call <SID>ShowMenu()<CR>



