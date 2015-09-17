let s:oldcpo = &cpo
set cpo-=< cpo+=B

" TODO trailing '\'

fun! s:TestCompileLiteralString( t ) "{{{

    let cases = []
    " cases: invalid "{{{
    let cases += [
          \ [ 'empty',
          \   '', 0,
          \   ['', 'EOF', 0],
          \ ],
          \ [ 'out of range',
          \   '', 1,
          \   ['', 'EOF', 1],
          \ ],
          \ [ 'out of range 5',
          \   '', 5,
          \   ['', 'EOF', 5],
          \ ],
          \
          \ [ 'x is not single quote',
          \   'x', 0,
          \   ['', 'InvalidInput', 0],
          \ ],
          \ [ '" is not single quote',
          \   '"', 0,
          \   ['', 'InvalidInput', 0],
          \ ],
          \ [ 'need right quote',
          \   "'", 0,
          \   ['', 'EOF', 0],
          \ ],
          \ [ 'need right quote after abc',
          \   "'abc", 0,
          \   ['', 'EOF', 0],
          \ ],
          \ ] "}}}
    " cases: valid "{{{
    let cases += [
          \ [ 'empty literal',
          \   "''", 0,
          \   ['', 'OK', 2],
          \ ],
          \ [ 'a',
          \   "'a'", 0,
          \   ['a', 'OK', 3],
          \ ],
          \ [ 'following content',
          \   "'a'bb", 0,
          \   ['a', 'OK', 3],
          \ ],
          \
          \ [ 'escaped',
          \   "''''", 0,
          \   ["'", 'OK', 4],
          \ ],
          \ [ 'incomplete escaped',
          \   "'''''", 0,
          \   ["", 'EOF', 0],
          \ ],
          \ [ 'escaped after other',
          \   "'a''b'''", 0,
          \   ["a'b'", 'OK', 8],
          \ ],
          \ [ 'with double quote',
          \   "'a''\"''b'", 0,
          \   ["a'\"'b", 'OK', 9],
          \ ],
          \ ] "}}}

    for [ case_desc, text, c, outp ] in cases

        let actual = xpsnip#snip#CompileLiteralString(text, c)
        let mes = a:t.Mes([case_desc, [text, c], outp], actual)

        call a:t.Eq( outp[0], actual[0], 'return-value of ' . mes )
        call a:t.Eq( outp[1], actual[1], 'error-code of ' . mes )
        call a:t.Eq( outp[2], actual[3], 'pos of ' . mes )

    endfor

endfunction "}}}

fun! s:TestCompileRegExp(t) "{{{

    let cases = []
    " cases: eof "{{{
    let cases += [
          \ [ 'empty',
          \   '', 0,
          \   ['', 'EOF', 0],
          \ ],
          \ [ 'out of range',
          \   '', 1,
          \   ['', 'EOF', 1],
          \ ],
          \ [ 'out of range 5',
          \   '', 5,
          \   ['', 'EOF', 5],
          \ ],
          \ [ 'x is not single /',
          \   'x', 0,
          \   ['', 'InvalidInput', 0],
          \ ],
          \ [ '" is not single /',
          \   '"', 0,
          \   ['', 'InvalidInput', 0],
          \ ],
          \ [ 'need right /',
          \   "/", 0,
          \   ['', 'EOF', 0],
          \ ],
          \ [ 'need right / after abc',
          \   "/abc", 0,
          \   ['', 'EOF', 0],
          \ ],
          \ ] "}}}
    " cases: valid "{{{
    let cases += [
          \ [ 'empty literal',
          \   "//", 0,
          \   ['', 'OK', 2],
          \ ],
          \ [ 'a',
          \   "/a/", 0,
          \   ['a', 'OK', 3],
          \ ],
          \ [ 'following content',
          \   "/a/bb", 0,
          \   ['a', 'OK', 3],
          \ ],
          \ ] "}}}
    " cases: escaping "{{{
    let cases += [
          \ [ 'escaped',
          \   '/\/\a/', 0,
          \   ['/\a', 'OK', 6],
          \ ],
          \ [ 'incomplete escaped',
          \   '/\/\/', 0,
          \   ["", 'EOF', 0],
          \ ],
          \ [ 'trailing escaped',
          \   '/\/\\/', 0,
          \   ['/\', 'OK', 6],
          \ ],
          \ [ 'escaped after other',
          \   '/a\/b\//', 0,
          \   ["a/b/", 'OK', 8],
          \ ],
          \ ] "}}}

    for [ case_desc, text, c, outp ] in cases

        let actual = xpsnip#snip#CompileRegExp(text, c)
        let mes = a:t.Mes([case_desc, [text, c], outp], actual)

        call a:t.Eq( outp[0], actual[0], 'return-value of ' . mes )
        call a:t.Eq( outp[1], actual[1], 'error-code of ' . mes )
        call a:t.Eq( outp[2], actual[3], 'pos of ' . mes )

    endfor
endfunction "}}}

fun! s:TestCompilePlaceHolder( t ) "{{{

    let cases = []

    " cases: invalid "{{{
    let cases += [
          \ [ 'empty',
          \   '', 0,
          \   [{}, 'EOF', 0],
          \ ],
          \ [ 'out of range',
          \   '', 1,
          \   [{}, 'EOF', 1],
          \ ],
          \ [ 'out of range 2',
          \   'x', 2,
          \   [{}, 'EOF', 2],
          \ ],
          \ [ 'empty at line 2',
          \   "abc\n", 4,
          \   [{}, 'EOF', 4],
          \ ],
          \
          \ [ 'no leading $',
          \   'x', 0,
          \   [{}, 'InvalidInput', 0],
          \ ],
          \ [ 'lack of name',
          \   '$', 0,
          \   [{}, 'EOF', 0],
          \ ],
          \ [ 'non-alpha name',
          \   '$-', 0,
          \   [{}, 'InvalidInput', 0],
          \ ],
          \ [ 'non-alpha quoted',
          \   '${-}', 0,
          \   [{}, 'InvalidInput', 0],
          \ ],
          \ [ 'unfinished quoted',
          \   '${-=', 0,
          \   [{}, 'InvalidInput', 0],
          \ ],
          \ [ 'invalid following char in quoted',
          \   '${x=}', 0,
          \   [{}, 'InvalidInput', 0],
          \ ],
          \ ] "}}}
    " cases: simple "{{{
    let cases += [
          \ [ 'simple name',
          \   '$x', 0,
          \   [{'name' : 'x'}, 'OK', 2],
          \ ],
          \
          \ [ 'simple quoted name',
          \   '${x}', 0,
          \   [{'name' : 'x'}, 'OK', 4],
          \ ],
          \ [ 'anonymous quoted name',
          \   '${}', 0,
          \   [{'name' : ''}, 'OK', 3],
          \ ],
          \ ] "}}}
    " cases: dot index "{{{
    let cases += [
          \ [ 'dot index: non-digit',
          \   '${x.x}', 0,
          \   [{}, 'InvalidPHIndex', 0],
          \ ],
          \ [ 'dot index: non-word',
          \   '${x.-}', 0,
          \   [{}, 'InvalidPHIndex', 0],
          \ ],
          \ [ 'dot index=0',
          \   '${x.0}', 0,
          \   [{'name' : 'x', 'index' : 0}, 'OK', 6],
          \ ],
          \ [ 'dot index=1',
          \   '${x.1}', 0,
          \   [{'name' : 'x', 'index' : 1}, 'OK', 6],
          \ ],
          \ [ 'dot index=01',
          \   '${x.01}', 0,
          \   [{'name' : 'x', 'index' : 1}, 'OK', 7],
          \ ],
          \ [ 'dot index=x1',
          \   '${x.x1}', 0,
          \   [{}, 'InvalidPHIndex', 0],
          \ ],
          \ [ 'dot index=123',
          \   '${x.123}', 0,
          \   [{'name' : 'x', 'index' : 123}, 'OK', 8],
          \ ],
          \ [ 'dot index=123, with following char',
          \   '${x.123}x', 0,
          \   [{'name' : 'x', 'index' : 123}, 'OK', 8],
          \ ],
          \ ] "}}}
    " cases: bracket index "{{{
    let cases += [
          \ [ 'bracket index: non-digit',
          \   '${x[x]}', 0,
          \   [{}, 'InvalidPHIndex', 0],
          \ ],
          \ [ 'bracket index: non-digit',
          \   '${x[x1]}', 0,
          \   [{}, 'InvalidPHIndex', 0],
          \ ],
          \ [ 'bracket index: non-word',
          \   '${x[-]}', 0,
          \   [{}, 'InvalidPHIndex', 0],
          \ ],
          \ [ 'bracket index=0',
          \   '${x[0]}', 0,
          \   [{'name' : 'x', 'index' : 0}, 'OK', 7],
          \ ],
          \ [ 'bracket index=1',
          \   '${x[1]}', 0,
          \   [{'name' : 'x', 'index' : 1}, 'OK', 7],
          \ ],
          \ [ 'bracket index=01',
          \   '${x[01]}', 0,
          \   [{'name' : 'x', 'index' : 1}, 'OK', 8],
          \ ],
          \ [ 'bracket index=123',
          \   '${x[123]}', 0,
          \   [{'name' : 'x', 'index' : 123}, 'OK', 9],
          \ ],
          \ [ 'bracket index=123, with following char',
          \   '${x[123]}x', 0,
          \   [{'name' : 'x', 'index' : 123}, 'OK', 9],
          \ ],
          \
          \ [ 'bracket index=123 no right bracket',
          \   '${x[123}', 0,
          \   [{}, 'NeedRightBracket', 0],
          \ ],
          \
          \ ] "}}}
    " cases: default value "{{{
    let cases += [
          \ [ 'incomplete ph with default value',
          \   '${x:', 0,
          \   [{}, 'EOF', 0],
          \ ],
          \ [ 'default value is empty expr',
          \   '${x:}', 0,
          \   [{'name' : 'x', 'def' : []}, 'OK', 5],
          \ ],
          \ [ 'default value is string abc',
          \   '${x:abc}', 0,
          \   [{'name' : 'x', 'def' : [['text', 'abc']]}, 'OK', 8],
          \ ],
          \ [ 'default value is literal abc',
          \   "${x:'abc'}", 0,
          \   [{'name' : 'x', 'def' : [['text', 'abc']]}, 'OK', 10],
          \ ],
          \ [ 'default value is quoted expression',
          \   '${x:"abc$(y)"}', 0,
          \   [{'name' : 'x',
          \     'def' : [
          \         ['text', 'abc'],
          \         ['snip', {'snipname' : 'y',
          \                   'param' : []
          \                  }]
          \     ]}, 'OK', 14],
          \ ],
          \ ] "}}}
    " cases: reg transform "{{{
    let cases += [
          \ [ 'incomplete ph with reg',
          \   '${x/', 0,
          \   [{}, 'EOF', 0],
          \ ],
          \ [ 'incomplete reg /',
          \   '${x/}', 0,
          \   [{}, 'EOF', 0],
          \ ],
          \ [ 'incomplete reg /x',
          \   '${x/x}', 0,
          \   [{}, 'EOF', 0],
          \ ],
          \ [ 'incomplete reg /x/',
          \   '${x/x/}', 0,
          \   [{}, 'EOF', 0],
          \ ],
          \ [ 'incomplete reg /x/y',
          \   '${x/x/y}', 0,
          \   [{}, 'EOF', 0],
          \ ],
          \ [ 'reg /x/y/',
          \   '${x/x/y/}', 0,
          \   [{'name' : 'x', 'post' : [['snip', {'snipname' : 'regtrans',
          \                                       'param' : [
          \                                             [['text', 'x']],
          \                                             [['text', 'y']],
          \                                       ]},
          \                             ]],
          \    }, 'OK', 9],
          \ ],
          \ [ 'reg /\/x/}y/',
          \   '${x/\/x/}y/}', 0,
          \   [{'name' : 'x', 'post' : [['snip', {'snipname' : 'regtrans',
          \                                       'param' : [
          \                                             [['text', '/x']],
          \                                             [['text', '}y']],
          \                                       ]},
          \                             ]],
          \    }, 'OK', 12],
          \ ],
          \ ] "}}}

    for [ case_desc, text, c, outp ] in cases

        let actual = xpsnip#snip#CompilePlaceHolder(text, c)
        let mes = a:t.Mes([case_desc, [text, c], outp], actual)

        call a:t.Eq( outp[0], actual[0], 'return-value of ' . mes )
        call a:t.Eq( outp[1], actual[1], 'error-code of ' . mes )
        call a:t.Eq( outp[2], actual[3], 'pos of ' . mes )

    endfor

endfunction "}}}

fun! s:TestCompileSnippetCallWithoutParameter( t ) "{{{

    let cases = []

    " cases: eof "{{{
    let cases += [
          \ [ 'empty',
          \   '', 0,
          \   [{}, 'EOF', 0],
          \ ],
          \ [ 'out of range',
          \   '', 1,
          \   [{}, 'EOF', 1],
          \ ],
          \ [ 'out of range 2',
          \   'x', 2,
          \   [{}, 'EOF', 2],
          \ ],
          \ [ 'empty at line 2',
          \   "abc\n", 4,
          \   [{}, 'EOF', 4],
          \ ],
          \ ] "}}}
    " cases: invalid "{{{
    let cases += [
          \ [ 'no leading $',
          \   'x', 0,
          \   [{}, 'InvalidInput', 0],
          \ ],
          \ [ 'lack of name',
          \   '$', 0,
          \   [{}, 'EOF', 0],
          \ ],
          \ [ 'not (',
          \   '$-', 0,
          \   [{}, 'InvalidInput', 0],
          \ ],
          \ [ 'non-alpha name',
          \   '$(-)', 0,
          \   [{}, 'InvalidInput', 0],
          \ ],
          \ [ 'unfinished quoted',
          \   '$(-=', 0,
          \   [{}, 'InvalidInput', 0],
          \ ],
          \ [ 'invalid following char',
          \   '$(x=)', 0,
          \   [{}, 'InvalidInput', 0],
          \ ],
          \ [ 'lack of )',
          \   '$(x', 0,
          \   [{}, 'EOF', 0],
          \ ],
          \ ] "}}}
    " cases: valid "{{{
    let cases += [
          \ [ 'simple',
          \   '$(x)', 0,
          \   [{'snipname' : 'x', 'param' : []}, 'OK', 4],
          \ ],
          \ [ 'following space',
          \   '$(x )', 0,
          \   [{'snipname' : 'x', 'param' : []}, 'OK', 5],
          \ ],
          \ [ 'leading space',
          \   '$( x)', 0,
          \   [{'snipname' : 'x', 'param' : []}, 'OK', 5],
          \ ],
          \
          \ [ 'anonymous',
          \   '$()', 0,
          \   [{}, 'OK', 3],
          \ ],
          \
          \ [ 'following char after )',
          \   '$(x)x', 0,
          \   [{'snipname' : 'x', 'param' : []}, 'OK', 4],
          \ ],
          \ ] "}}}
    " cases: param "{{{
    let cases += [
          \ [ 'param=a',
          \   '$(x a)', 0,
          \   [{'snipname' : 'x', 'param' : [[['text', 'a']]]}, 'OK', 6],
          \ ],
          \ [ 'param=$a',
          \   '$(x $a)', 0,
          \   [{'snipname' : 'x', 'param' : [[['ph', {'name' : 'a'}]]]}, 'OK', 7],
          \ ],
          \ [ 'param=${a}',
          \   '$(x ${a.01})', 0,
          \   [{'snipname' : 'x', 'param' : [
          \         [['ph', {'name' : 'a', 'index' : 1}]]
          \    ]}, 'OK', 12],
          \ ],
          \ [ 'param=$a$b',
          \   '$(x $a$b)', 0,
          \   [{'snipname' : 'x', 'param' : [
          \         [['ph', {'name' : 'a'}], ['ph', {'name' : 'b'}]]
          \    ]}, 'OK', 9],
          \ ],
          \ [ '2 params: $a $b',
          \   '$(x $a $b)', 0,
          \   [{'snipname' : 'x', 'param' : [
          \         [['ph', {'name' : 'a'}]],
          \         [['ph', {'name' : 'b'}]]
          \    ]}, 'OK', 10],
          \ ],
          \ [ 'literal string params',
          \   "$(x '$a' $b)", 0,
          \   [{'snipname' : 'x', 'param' : [
          \         [['text', '$a']],
          \         [['ph', {'name' : 'b'}]]
          \    ]}, 'OK', 12],
          \ ],
          \ [ 'double quote params',
          \   '$(x "$a " $b)', 0,
          \   [{'snipname' : 'x', 'param' : [
          \         [['ph', {'name' : 'a'}], ['text', ' ']],
          \         [['ph', {'name' : 'b'}]]
          \    ]}, 'OK', 13],
          \ ],
          \ [ 'params seperated by <tab><space>',
          \   '$(x	"$a "	 $b)', 0,
          \   [{'snipname' : 'x', 'param' : [
          \         [['ph', {'name' : 'a'}], ['text', ' ']],
          \         [['ph', {'name' : 'b'}]]
          \    ]}, 'OK', 14],
          \ ],
          \ ] "}}}

    for [ case_desc, text, c, outp ] in cases

        let actual = xpsnip#snip#CompileSnippetCall(text, c)
        let mes = a:t.Mes([case_desc, [text, c], outp], actual)

        call a:t.Eq( outp[0], actual[0], 'return-value of ' . mes )
        call a:t.Eq( outp[1], actual[1], 'error-code of ' . mes )
        call a:t.Eq( outp[2], actual[3], 'pos of ' . mes )

    endfor

endfunction "}}}

fun! s:TestCompileExpr( t ) "{{{

    let cases = []

    " cases: literal "{{{
    let cases += [
          \ [ 'empty',
          \   '', 0, '',
          \   [[], 'OK', 0],
          \ ],
          \ [ 'out of range',
          \   '', 1, '',
          \   [[], 'EOF', 1],
          \ ],
          \ [ 'out of range 5',
          \   'aa', 5, '',
          \   [[], 'EOF', 5],
          \ ],
          \
          \ [ 'a',
          \   'a', 0, '',
          \   [[['text', 'a']], 'OK', 1],
          \ ],
          \ [ 'abc',
          \   'abc', 0, '',
          \   [[['text', 'abc']], 'OK', 3],
          \ ],
          \ [ 'abc from 2nd',
          \   'abc', 1, '',
          \   [[['text', 'bc']], 'OK', 3],
          \ ],
          \
          \ [ 'unescape $ only',
          \   '\a\b\$\\\$\{\[\\a\\$a', 0, '',
          \   [[['text', '\a\b$\$\{\[\\a\'],
          \     ['ph', {'name' : 'a'}]], 'OK', 21],
          \ ],
          \
          \ [ 'with space and escaped space',
          \   'a b\ c	d', 0, '',
          \   [[['text', 'a b\ c	d']], 'OK', 8],
          \ ],
          \ ] "}}}
    " cases: ph "{{{
    let cases += [
          \ [ 'with anonymous ph',
          \   'a${}b', 0, '',
          \   [[['text', 'a'], ['ph', {'name':''}], ['text', 'b']], 'OK', 5],
          \ ],
          \ [ 'anonymous ph at start',
          \   '${}b', 0, '',
          \   [[['ph', {'name':''}], ['text', 'b']], 'OK', 4],
          \ ],
          \ [ 'anonymous ph at end',
          \   'a${}', 0, '',
          \   [[['text', 'a'], ['ph', {'name':''}]], 'OK', 4],
          \ ],
          \ [ 'incomplete anonymous ph',
          \   'a${', 0, '',
          \   [[], 'EOF', 0],
          \ ],
          \
          \
          \ [ 'ph a',
          \   'a$a', 0, '',
          \   [[['text', 'a'], ['ph', {'name':'a'}]], 'OK', 3],
          \ ],
          \ [ 'ph a, quoted',
          \   'a${a}', 0, '',
          \   [[['text', 'a'], ['ph', {'name':'a'}]], 'OK', 5],
          \ ],
          \ [ 'ph a, with dot index',
          \   'a${a.11}', 0, '',
          \   [[['text', 'a'], ['ph', {'name':'a', 'index':11}]], 'OK', 8],
          \ ],
          \ [ 'ph a, with bracket index',
          \   'a${a[11]}b', 0, '',
          \   [[['text', 'a'], ['ph', {'name':'a', 'index':11}], ['text', 'b']], 'OK', 10],
          \ ],
          \ ] "}}}
    " cases: endchar "{{{
    let cases += [
          \ [ 'string end at "',
          \   'a"a', 0, '"',
          \   [[['text', 'a']], 'OK', 1],
          \ ],
          \ [ 'string end at ", with space',
          \   'a "a', 0, '"',
          \   [[['text', 'a ']], 'OK', 2],
          \ ],
          \
          \ [ 'string end at ", with space, reg',
          \   'a "a', 0, '"',
          \   [[['text', 'a ']], 'OK', 2],
          \ ],
          \
          \ [ 'end at "',
          \   'a$"a', 0, '"',
          \   [[], 'EOF', 0],
          \ ],
          \ [ 'end at ", complete expr',
          \   'a${x}"a', 0, '"',
          \   [[['text', 'a'], ['ph', {'name':'x'}]], 'OK', 5],
          \ ],
          \ [ 'end at <space>, complete expr',
          \   'a${x}a b', 0, ' ',
          \   [[['text', 'a'], ['ph', {'name':'x'}], ['text', 'a']], 'OK', 6],
          \ ],
          \
          \ [ 'not end at escaped "',
          \   'a\"a"b', 0, '"',
          \   [[['text', 'a"a']], 'OK', 4],
          \ ],
          \
          \ ] "}}}
    " cases: snip call "{{{
    let cases += [
          \ [ 'snip x',
          \   'a$(x)a b', 0, ' ',
          \   [[['text', 'a'],
          \     ['snip', {'snipname':'x', 'param' : []}],
          \     ['text', 'a']
          \    ], 'OK', 6],
          \ ],
          \ [ 'snip abc, with 2 param',
          \   'a$(x y${z}u "$x")a b', 0, ' ',
          \   [[['text', 'a'],
          \     ['snip', {'snipname' : 'x', 'param' : [
          \                 [['text', 'y'],
          \                  ['ph', {'name' : 'z'}],
          \                  ['text', 'u'],
          \                 ],
          \                 [['ph', {'name' : 'x'}]],
          \               ]}],
          \     ['text', 'a']
          \    ], 'OK', 18],
          \ ],
          \ ] "}}}

    for [ case_desc, text, c, endchar, outp ] in cases

        let actual = xpsnip#snip#CompileExpr(text, c, endchar)
        let mes = a:t.Mes([case_desc, [text, c, endchar], outp], actual)

        call a:t.Eq( outp[0], actual[0], 'return-value of ' . mes )
        call a:t.Eq( outp[1], actual[1], 'error-code of ' . mes )
        call a:t.Eq( outp[2], actual[3], 'pos of ' . mes )

    endfor

endfunction "}}}


exec xpsnip#unittest#run
let &cpo = s:oldcpo
