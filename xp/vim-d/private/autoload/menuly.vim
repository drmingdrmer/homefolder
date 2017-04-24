" menu item:
" string:   setting toggle
" list:     ['settingname', val1, val2...]
" list:     ['settingname', function]
" list:     ['settingname', sub_menu_dict]
" dict:     {"scope": "global|buffer|window", "xx": ['settingname', val1, val2..]}
"
" ctx:      {
"       nth_call: 0,
" }
let s:settings = {
            \'.c' :  'clean',
            \'.fc':  'foldcolumn',
            \
            \'x'  :  'conceal',
            \'cc' :  'cursorcolumn',
            \'cl' :  'cursorline',
            \'l'  :  'list',
            \'m'  :  'modifiable',
            \'n'  :  'number',
            \'tl' :  'showtabline',
            \'p'  :  'spell',
            \'r'  :  'wrap',
            \}

let s:switchers = {}
let g:xp_switchers = s:switchers
fun! s:switchers.conceal(ctx) "{{{
    if &l:conceallevel == 0
        setlocal conceallevel=2
        setlocal concealcursor=nv
    else
        setlocal conceallevel=0
        setlocal concealcursor=
    endif
endfunction "}}}
fun! s:switchers.clean(ctx) "{{{
    if &showtabline == 0
        set showtabline=2
        set laststatus=2
        set ruler
        set number
        set cmdheight=2
        call system('tmux set status on >/dev/null 2>/dev/null')
        call system('screen -X hardstatus alwayslastline >/dev/null 2>/dev/null')
    else
        set showtabline=0
        set laststatus=0
        set noruler
        set nonumber
        set cmdheight=1
        call system('tmux set status off >/dev/null 2>/dev/null')
        call system('screen -X hardstatus ignore >/dev/null 2>/dev/null')
    endif
endfunction "}}}
let s:switchers.showtabline = [0, 2]
let s:switchers.foldcolumn = [0, 3]

fun! menuly#GetContext(scope, menu_names) "{{{
    let node = {}
    if a:scope == 'local'
        if ! exists('b:menuly')
            let b:menuly = {}
        endif
        let node = b:menuly
    elseif a:scope == 'window'
        if ! exists('w:menuly')
            let w:menuly = {}
        endif
        let node = w:menuly
    else
        if ! exists('g:menuly')
            let g:menuly = {}
        endif
        let node = g:menuly
    endif

    for name in a:menu_names
        if ! has_key(node, name)
            let node[name] = { "nth_call": 0 }
        endif
        let node = node[name]
    endfor

    let node.nth_call += 1

    return node
endfunction "}}}


fun! menuly#NormalizeMenu(menu) "{{{
    let norm_menu = {}
    for [key, item] in items(a:menu)
        let norm_menu[key] = menuly#NormalizeMenuItem(item)
    endfor
    return norm_menu
endfunction "}}}


fun! menuly#NormalizeMenuItem(menu_item) "{{{

    let item = a:menu_item
    let norm = {}

    if type(item) == type('')

        if item[0] == ':'
            let norm = {
                  \ "title": item,
                  \ "scope": "global",
                  \ "command": item[1 : ],
                  \ }
        else
            let norm = {
                  \ "title": item,
                  \ "scope": "local",
                  \ "setting": item,
                  \ }
        endif


    elseif type(item) == type([])

        if type(item[1]) == type({})

            let sub_menu = item[1]
            let new_submenu = {}
            for key in keys(sub_menu)
                let subitem = sub_menu[key]
                let new_submenu[key] = menuly#NormalizeMenuItem(subitem)
            endfor

            let norm = {
                  \ "title": item[0],
                  \ "submenu": new_submenu,
                  \ }

        elseif type(item[1]) == type(function("tr"))

            let norm = {
                  \ "title": item[0],
                  \ "func": item[1],
                  \ }

        else

            " [setting, value-1, value-2]

            let norm = {
                  \ "title": item[0],
                  \ "scope": "local",
                  \ "setting": item[0],
                  \ "values": item[1:-1],
                  \ }
        endif

    elseif type(item) == type({})

        " already normal
        let norm = item

    endif

    if has_key(norm, 'submenu')
        let norm.submenu = menuly#NormalizeMenu(norm.submenu)
    endif

    return norm

endfunction "}}}

fun! menuly#MakeTitle(menu_item) "{{{

    let item = a:menu_item

    if type(item) == type({})
        return get(item, '_title', 'no-title')
    endif

    return 'xxx'

endfunction "}}}

fun! menuly#SortMenu(a, b) "{{{
    let [a, b] = [a:a, a:b]
    if a[0] == b[0]
        return 0
    elseif a[0] > b[0]
        return 1
    else
        return -1
    endif
endfunction "}}}

fun! menuly#ShowMenu(menu_title, menu_dict) "{{{

    let pref = ''
    while 1

        let matched = []
        for [keystroke, val] in items(a:menu_dict)

            let subkey = strpart(keystroke, 0, len(pref))
            if pref == keystroke
                return [pref, a:menu_dict[pref]]
            endif

            if pref == subkey
                let matched += [[keystroke, val]]
            endif
        endfor

        if matched == []
            return ['', {}]
        endif

        call sort(matched, function('menuly#SortMenu'))

        let lines = []
        for [keystroke, val] in matched
            let lines += menuly#MakeMenuItemStr(keystroke, val, 0)
        endfor

        let &cmdheight = len(lines) + 1 + 1
        redraw!

        for l in lines
            echo l
        endfor

        echohl WildMenu
        echo a:menu_title
        echohl None

        try
            let c = input#GetChar('')
        catch /.*/
            " maybe <C-c> by user
            return ['', {}]
        endtry

        if c == ''
            " cancel char pressed
            return ['', {}]
        elseif c == "\<BS>"
            let pref = pref[:-2]
        else
            let pref .= c
        endif
    endwhile

endfunction " }}}

fun! menuly#MakeMenuItemStr(keystroke, item, indent) "{{{

    let keystroke = a:keystroke
    let item = a:item
    let indent = repeat(' ', a:indent)

    " let lines = [printf('%-4s%s - %s', keystroke . ')', repeat(' ', indent), item.title)]
    let lines = [printf('%s%-4s%s', indent, keystroke . ':', item.title)]

    if has_key(item, 'submenu')
        let sub_lines = items(item.submenu)
        call sort(sub_lines, function('menuly#SortMenu'))
        let last = lines[-1]

        let _sub = []
        for [_k, _item] in sub_lines
            let _sub += menuly#MakeMenuItemStr(_k, _item, a:indent + 4)
        endfor

        let lines += _sub
    endif

    return lines

endfunction "}}}

fun! menuly#xxx() "{{{

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



