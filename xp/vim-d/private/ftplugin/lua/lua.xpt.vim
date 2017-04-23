XPTemplate priority=lang

XPTinclude
      \ _common/common

XPT case
function test.`foo^(t)

    local cases = {
        {`cursor^},
    }

    for ii, c in ipairs(cases) do

        local inp, expected, desc = unpack(c)
        local msg = 'case: ' .. tostring(ii) .. '-th: '
        dd(msg, c)

        local rst = `foo^(inp)
        dd('rst: ', rst)

        t:eq(expected, rst, msg)
    end
end
