XPTemplate priority=sub

let s:f = g:XPTfuncs()

XPTinclude
      \ _common/common

fun! s:f.ModName()
    let fn = expand('%:t')
    let fn = matchstr(fn, '\Vtest_\zs\.\*\ze.c')
    return fn
endfunction

XPT ##
/* `cursor^ */



XPT ut " st_test(fn, name)
st_test(`ModName()^, `func^) {

    struct case_s {
        uint64_t inp;
        uint64_t expected;
    } cases[] = {
        {0, 0},
    };

    for (int i = 0; i < st_nelts(cases); i++) {
        st_typeof(cases[0])   c = cases[i];
        st_typeof(c.expected) rst = `func^(c.inp, c.upto);

        ddx(rst);

        st_ut_eq(c.expected, rst, "");
    }
}
