exe xpsnip#once#init

let s:oldcpo = &cpo
set cpo-=< cpo+=B

let s:eof = '(eof)'

fun! xpsnip#snip#Compile(text, c, endchar) abort "{{{

    let [c, text] = [a:c, a:text]

    let chr = text[c]

    if chr == "'"
        let [str, err, mes, cc] = xpsnip#snip#CompileLiteralString(text, c)
        if err == 'OK'
            return [[['text', str]], err, mes, cc]
        else
            return [[], err, mes, cc]
        endif

    elseif chr == '"'
        let [expr, err, mes, cc] = xpsnip#snip#CompileExpr(text, c+1, '"')
        if err == 'OK'
            let cc += 1
        endif
        return [expr, err, mes, cc]

    else
        let [expr, err, mes, cc] = xpsnip#snip#CompileExpr(text, c, a:endchar)
        return [expr, err, mes, cc]
    endif
endfunction "}}}

fun! xpsnip#snip#CompileExpr(text, c, endchar) abort "{{{

    echo 'compile expr:' a:text string(a:text[ a:c : ])

    let endchar = a:endchar

    let status = 'literal_str'

    let [expr, err, mes] = [[], 'Unknown', '']
    let [c, text, l] = [a:c - 1, a:text, strlen(a:text)]
    let chrlist = split(text, '\v.\zs') + [s:eof]

    if c >= l
        let [err, mes] = s:errExpcet("non-(eof)", c, s:eof, text)
        return [[], err, mes, a:c]
    endif

    let buf = ''
    while status != 'done'
        let c += 1
        let chr = chrlist[c]
        if endchar != '' && chr =~ '\v['.endchar.']'
            let chr = s:eof
        endif

        " let indent_tabs = matchstr(text, '\v^\t*')
        " let [prev_indent, cur_indent] = [cur_indent, strlen(indent_tabs)]
        " let c = cur_indent

        echo '    compile expr: status and chr: ' . status . ' ' . string(chr)

        if status != 'literal_str'
            if chr == s:eof
                let [err, mes] = s:errExpcet("non-(eof)", c, chr, text)
                break
            endif
        endif

        if status =='literal_str'

            if chr == s:eof
                let status = 'done'
                let err = 'OK'

            elseif chr == '$'
                let status = 'dollar'

            else
                let chrs = '$' . endchar
                let buf = matchstr(text, '\v([^' . chrs . ']|(\\\\)*\\['.chrs.'])*', c)
                echo text
                echo '\v([^\\'.chrs.']|(\\\\)*\\['.chrs.']|\\*[^'.chrs.'])*'
                echo c
                echo buf
                let expr += [['text', buf]]
                let c += strlen(buf) - 1
            endif

        elseif status == 'escape'

            if chr == '$'
                let nbackslash = strlen(escapebuf)
                let buf .= repeat('\', nbackslash / 2)
                if nbackslash % 2 == 0
                    let c = c - 1
                else
                    let buf .= chr
                endif
            else
                let buf .= escapebuf . chr
            endif

            let status = 'literal_str'
            let escapebuf = ''

        elseif status == 'dollar'
            if chr == '{' || chr =~ '\v\w'
                let [ph, err, mes, cc] = xpsnip#snip#CompilePlaceHolder(text, c-1)
                if err == 'OK'
                    let expr += [['ph', ph]]
                    let c = cc - 1
                    let status = 'literal_str'
                else
                    break
                endif

            elseif chr == '('
                let [scall, err, mes, cc] = xpsnip#snip#CompileSnippetCall(text, c-1)
                if err == 'OK'
                    let expr += [['snip', scall]]
                    let c = cc - 1
                    let status = 'literal_str'
                else
                    break
                endif
            else
                let [err, mes] = s:errExpcet("{|(|\w", c, chr, text)
                break
            endif
        endif

    endwhile


    if err == 'OK'
        let pos = c
    else
        let expr = []
        let pos = a:c
    endif
    return [expr, err, mes, pos]
endfunction "}}}

fun! xpsnip#snip#CompilePlaceHolder(text, c) abort "{{{

    " echo 'compile ph'

    let status = 'init'
    let [ph, err, mes] = [{}, 'Unknown', '']
    let [c, text, l] = [a:c - 1, a:text, strlen(a:text)]

    let chr = 'xx'
    while 1
        let c += 1
        if c >= l
            let chr = s:eof
        else
            let chr = text[c]
        endif

        " echo '    compile ph: status and chr: ' . status . ' ' . chr

        if status == 'done'
            break
        endif

        if status != 'init' && chr == s:eof
            let [err, mes] = s:errExpcet("non-(eof)", c, chr, text)
            break
        endif

        if status =='init'
            if chr == '$'
                let status = 'dollar'
            else
                let [err, mes] = s:errExpcet("'", c, chr, text)
                break
            endif

        elseif status == 'dollar'
            if chr == '{'
                let status = 'quoted_ph'

            elseif chr =~ '\v\w'
                let phname = matchstr(text, '\v^\w+', c)
                let c += strlen(phname) - 1
                let ph = { 'name' : phname, }
                let err = 'OK'
                let status = 'done'

            else
                let [err, mes] = s:errExpcet("{|\w", c, chr, text)
                break
            endif

        elseif status == 'quoted_ph'
            if chr == '}'
                let ph = { 'name' : '' }
                let err = 'OK'
                let status = 'done'

            elseif chr =~ '\v\w'
                let phname = matchstr(text, '\v^\w+', c)
                let c += strlen(phname) - 1
                let ph = { 'name' : phname, }
                let status = 'ph_decor'
            else
                let [err, mes] = s:errExpcet("}|\w", c, chr, text)
                break
            endif

        elseif status == 'ph_decor'
            if chr == '.'
                let status = 'dot_index'
            elseif chr == '['
                let status = 'bracket_index'
            elseif chr == ':'
                let status = 'default_val'
            elseif chr == '/'
                let ph.post = [['snip', {'snipname' : 'regtrans', 'param' : []}]]
                let status = 'reg_trans_reg'
            elseif chr == '}'
                let err = 'OK'
                let status = 'done'
            else
                let [err, mes] = s:errExpcet("[.\[:/}]", c, chr, text)
                break
            endif

        elseif status == 'dot_index'
            let [idx, err, mes, cc] = s:readIndex(text, c, ph)
            if err == 'OK'
                let [c, status] = [cc-1, 'ph_decor']
            else
                break
            endif

        elseif status == 'bracket_index'
            let [idx, err, mes, cc] = s:readIndex(text, c, ph)
            if err == 'OK'
                let [c, status] = [cc-1, 'bracket_right']
            else
                break
            endif

        elseif status == 'bracket_right'
            if chr == ']'
                let status = 'ph_decor'
            else
                let [err, mes] = ['NeedRightBracket', s:errmes(']', c, chr, text)]
                break
            endif

        elseif status == 'default_val'
            let [expr, err, mes, cc] = xpsnip#snip#Compile(text, c, '}')

            if err == 'OK'
                let ph.def = expr
                let c = cc - 1
                let status = 'ph_decor'
            else
                break
            endif

        elseif status == 'reg_trans_reg'

            let [reg, err, mes, cc] = xpsnip#snip#CompileRegExp(text, c-1)

            if err == 'OK'
                let c = cc - 1
                let ph.post[0][1].param += [[['text', reg]]]
                let status = 'reg_trans_replacement'

            else
                break
            endif

        elseif status == 'reg_trans_replacement'

            let [reg, err, mes, cc] = xpsnip#snip#CompileRegExp(text, c-1)

            if err == 'OK'
                let c = cc - 1
                let ph.post[0][1].param += [[['text', reg]]]
                let status = 'ph_decor'

            else
                break
            endif
        endif

    endwhile

    if err == 'OK'
        let pos = c
    else
        let ph = {}
        let pos = a:c
    endif

    return [ph, err, mes, pos]

endfunction "}}}

fun! xpsnip#snip#CompileSnippetCall(text, c) abort "{{{

    " echo 'compile snippet'

    let status = 'init'
    let [scall, err, mes] = [{}, 'Unknown', '']
    let [c, text, l] = [a:c - 1, a:text, strlen(a:text)]

    let chr = 'xx'
    while chr != s:eof
        let c += 1
        if c >= l
            let chr = s:eof
        else
            let chr = text[c]

            " let indent_tabs = matchstr(text, '\v^\t*')
            " let [prev_indent, cur_indent] = [cur_indent, strlen(indent_tabs)]
            " let c = cur_indent
        endif

        " echo '    compile ph: status and chr: ' . status . ' ' . chr

        if status == 'done'
            break
        endif

        if status != 'init'
            if chr == s:eof
                let [err, mes] = s:errExpcet("non-(eof)", c, chr, text)
                break
            endif
        endif

        if status =='init'
            if chr == '$'
                let status = 'dollar'
            else
                let [err, mes] = s:errExpcet("'", c, chr, text)
                break
            endif

        elseif status == 'dollar'
            if chr == '('
                let status = 'left_parentheses'
            else
                let [err, mes] = s:errExpcet("(", c, chr, text)
                break
            endif

        elseif status == 'left_parentheses'

            if chr =~ '\v^\s*$'
                continue

            elseif chr =~ '\v\w'
                let n = matchstr(text, '\v^\w+', c)
                let scall = { 'snipname' : n, 'param' : [] }
                let c += strlen(n) - 1
                let status = 'space_before_param'

            elseif chr == ')'
                let scall = {}
                let err = 'OK'
                let status = 'done'
            else
                let [err, mes] = s:errExpcet('\w', c, chr, text)
                break
            endif

        elseif status == 'space_before_param'

            if chr =~ '\v^\s$'
                let sp = matchstr(text, '\v^\s*', c)
                let c += strlen(sp) - 1
                let status = 'param'
            elseif chr == ')'
                let err = 'OK'
                let status = 'done'
            else
                let [err, mes] = s:errExpcet('\s', c, chr, text)
                break
            endif

        elseif status == 'param'

            if chr == ')'
                let err = 'OK'
                let status = 'done'

            elseif chr == "'"
                let [str, err, mes, cc] = xpsnip#snip#CompileLiteralString(text, c)
                if err == 'OK'
                    let scall.param += [[['text', str]]]
                    let c = cc - 1
                    let status = 'space_before_param'
                else
                    break
                endif

            elseif chr == '"'
                let [expr, err, mes, cc] = xpsnip#snip#CompileExpr(text, c+1, '"')
                if err == 'OK'
                    let scall.param += [expr]
                    " skip the quote
                    let c = cc
                    let status = 'space_before_param'
                else
                    break
                endif

            else
                let [expr, err, mes, cc] = xpsnip#snip#CompileExpr(text, c, ' \t)')
                if err == 'OK'
                    let scall.param += [expr]
                    let c = cc - 1
                    let status = 'space_before_param'
                else
                    break
                endif

            endif
        endif

    endwhile

    if err == 'OK'
        let pos = c
    else
        let scall = {}
        let pos = a:c
    endif

    return [scall, err, mes, pos]

endfunction "}}}

fun! xpsnip#snip#CompileLiteralString(text, c) abort "{{{

    " echo 'compile literal string' a:text a:c a:text[ a:c : ]

    let status = 'init'

    let [buf, err, mes] = ['', 'Unknown', '']
    let [c, text] = [a:c - 1, a:text]

    let chr = 'xx'
    while chr != s:eof
        let c += 1
        if c >= strlen(text)
            let chr = s:eof
        else
            let chr = text[c]
        endif

        if status =='init'
            if chr == "'"
                let status = 'literal'
            else
                let [err, mes] = s:errExpcet("'", c, chr, text)
                break
            endif

        elseif status == 'literal'
            if chr == "'"
                let status = 'quote_1'
            elseif chr == s:eof
                let [err, mes] = s:errExpcet("non-(eof)", c, chr, text)
                break
            else
                let cc = matchstr(text, '\v^[^'']*', c)
                let c += strlen(cc) - 1
                let buf .= cc
            endif

        elseif status == 'quote_1'
            if chr == "'"
                let buf .= "'"
                let status = 'literal'
            else
                let err = 'OK'
                break
            endif
        endif
    endwhile

    if err == 'OK'
        let pos = c
    else
        let buf = ''
        let pos = a:c
    endif

    return [buf, err, mes, pos]
endfunction "}}}

fun! xpsnip#snip#CompileRegExp(text, c) abort "{{{

    " echo 'compile regexp' a:text a:c a:text[ a:c : ]

    let status = 'init'

    let [buf, err, mes] = ['', 'Unknown', '']
    let [c, text] = [a:c - 1, a:text]

    let escapebuf = ''

    let chr = 'xx'
    while chr != s:eof
        let c += 1
        if c >= strlen(text)
            let chr = s:eof
        else
            let chr = text[c]

            " let indent_tabs = matchstr(text, '\v^\t*')
            " let [prev_indent, cur_indent] = [cur_indent, strlen(indent_tabs)]
            " let c = cur_indent
        endif

        " echo '    compile regexp: status and chr: ' . status . ' ' . string(chr)

        if status == 'done'
            break
        endif

        if status =='init'
            if chr == '/'
                let status = 'literal'
            else
                let [err, mes] = s:errExpcet("'", c, chr, text)
                break
            endif

        elseif status == 'literal'
            if chr == '\'
                let escapebuf .= chr
                let status = 'escape'
            elseif chr == '/'
                let err = 'OK'
                let status = 'done'
            elseif chr == s:eof
                let [err, mes] = s:errExpcet("non-(eof)", c, chr, text)
                break
            else
                let cc = matchstr(text, '\v^[^\\/]*', c)
                let c += strlen(cc) - 1
                let buf .= cc
            endif

        elseif status == 'escape'
            if chr == '\'
                let escapebuf .= chr
                continue
            endif

            if chr == '/'
                let nbackslash = strlen(escapebuf)
                let buf .= repeat('\', nbackslash / 2)
                if nbackslash % 2 == 0
                    let c = c - 1
                else
                    let buf .= chr
                endif
            else
                let buf .= escapebuf . chr
            endif

            let status = 'literal'
            let escapebuf = ''
        endif
    endwhile

    if err == 'OK'
        let pos = c
    else
        let buf = ''
        let pos = a:c
    endif

    return [buf, err, mes, pos]
endfunction "}}}

fun! s:readIndex(text, c, ph) abort "{{{
    let [text, c] = [a:text, a:c]

    let chr = text[c]

    if chr =~ '\v\d'
        let _ph_index = matchstr(text, '\v^\d+', c)
        let a:ph.index = _ph_index + 0
        return [0, 'OK', '', c + len(_ph_index) ]
    else
        return [0, 'InvalidPHIndex', s:errmes("[0-9]", c, chr, text), c ]
    endif

endfunction "}}}
fun! s:errExpcet(expect, c, chr, text) abort "{{{
    if a:chr == s:eof
        let err = 'EOF'
    else
        let err = 'InvalidInput'
    endif
    return [err, s:errmes(a:expect, a:c, a:chr, a:text)]
endfunction "}}}
fun! s:errmes(expect, c, chr, text) abort "{{{
    return printf('expect %s at %d but it is %s; text=%s',
          \ a:expect, a:c, a:chr, a:text)
endfunction "}}}

let &cpo = s:oldcpo
