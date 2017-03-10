if exists("g:__MENULY_VIM_jfklsdfjdksl__")
    finish
endif
let g:__MENULY_VIM_jfklsdfjdksl__ = 1

let g:menuly_menu = {
      \ 'c': ['cursor', {
      \          'l': 'cursorline',
      \          'r': 'cursorcolumn',
      \ }],
      \ 'f': ['folding', {
      \          'c': ['foldcolumn', 0, 3],
      \          'm': ['foldmethod', 'manual', 'indent', 'expr', 'marker', 'syntax', 'diff'],
      \ }],
      \ 'l': 'list',
      \ 'm': 'modifiable',
      \ 'n': 'number',
      \ 'p': 'spell',
      \ 't': ['tabline', {
      \         'l': ['showtabline', 0, 2],
      \ }],
      \ 'w': 'wrap',
      \ }

fun! s:ShowMenu(...) "{{{

    let oldcmdheight = &cmdheight

    let prefixes = ['menuly']
    let menu_dict = menuly#NormalizeMenu(g:menuly_menu)
    let menu_title = join(prefixes, ' > ') . ' >'
    while 1
        let [pref, menu_item] = menuly#ShowMenu(menu_title, menu_dict)

        if has_key(menu_item, 'submenu')
            let menu_dict = menu_item.submenu
            let prefixes += [menu_item.title]
            let menu_title = join(prefixes, ' > ') . ' >'
        else
            break
        endif
    endwhile

    let &cmdheight = oldcmdheight
    redraw!

    if pref == ''
        return ''
    endif

    let prefixes += [menu_item.title]

    let ctx = menuly#GetContext(menu_item.scope, prefixes)

    if menu_item.scope == 'local'
        let scope_key = 'l:'
    elseif menu_item.scope == 'window'
        let scope_key = 'l:'
    else
        let scope_key = ''
    endif

    if has_key(menu_item, 'setting')

        let setting_name = menu_item.setting

        if has_key(menu_item, 'values')
            let values = menu_item.values
            let setting_value = values[ctx.nth_call % len(values)]
            let cmd = "let &" . scope_key . setting_name . "=" . string(setting_value)
        else
            if scope_key == 'l:'
                let cmd = "setlocal " . setting_name . "!"
            else
                let cmd = "set " . setting_name . '!'
            endif
        endif

        exe 'silent' cmd
        exe 'echo "' scope_key . setting_name . '="&' . scope_key . setting_name
    endif


endfunction "}}}

" expr mapping does not work with redraw
nmap \ :call <SID>ShowMenu()<CR>
