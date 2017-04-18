XPTemplate priority=lang

let s:f = g:XPTfuncs()

" use snippet 'varConst' to generate contant variables
" use snippet 'varFormat' to generate formatting variables
" use snippet 'varSpaces' to generate spacing variables


XPTinclude
      \ _common/common


XPT case
function test.`foo^(t)

    local cases = {
        {`cursor^},
    }

    for ii, c in ipairs(cases) do
        local inp, expected, desc = unpack(c)

        local rst = `foo^(inp)
        t:eq(expected, rst, tostring(i) .. 'th: ' .. desc)
    end
end
