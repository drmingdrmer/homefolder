XPTemplate priority=lang

let s:f = g:XPTfuncs()

XPTinclude
      \ _common/common

fun! s:f.ModName()
    let fn = expand('%:t')
    let fn = matchstr(fn, '\Vtest_\zs\.\*\ze.lua')
    return fn
endfunction

fun! s:f.CountInput()
    let v = self.ItemValue()
    let v = substitute(v, '\v[^,]', '', 'g')
    return strlen(v) + 1
endfunction

XPT case
function test.`foo^(t)

    for `inp^, expected, desc in t:case_iter(`inp^CountInput()^, {
        {`cursor^},
    }) do

        local rst = `ModName()^.`foo^(`inp^)
        dd('rst: ', rst)

        t:eq(expected, rst, desc)
    end
end
