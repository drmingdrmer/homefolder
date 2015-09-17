if exists("g:__autoload_xpsnip_unittest__")
    finish
endif
let g:__autoload_xpsnip_unittest__ = 1

let s:oldcpo = &cpo
set cpo-=< cpo+=B

let xpsnip#unittest#run = 'exe xpsnip#util#let_sid | call xpsnip#unittest#RunMe(s:sid, expand("<sfile>"))'

let s:ctx = {}

fun! s:ctx.True( val, mes ) abort "{{{
    if a:val
        " ok
    else
        throw a:mes
    endif
endfunction "}}}
fun! s:ctx.Eq( a, b, mes ) abort "{{{
    call self.True( type(a:a) == type(a:b) && a:a == a:b,
          \ "Expect " . string(a:a) . " But " . string(a:b) . " " .a:mes )
endfunction "}}}
fun! s:ctx.Ne( a, b, mes ) abort "{{{
    call self.True( a:a != a:b,
          \ "Expect not to be " . string(a:a) . " But " . string(a:b) . " " .a:mes )
endfunction "}}}
fun! s:ctx.Is( a, b, mes ) abort "{{{
    call self.True( a:a is a:b,
          \ "Expect is " . string(a:a) . " But " . string(a:b) . " " .a:mes )
endfunction "}}}
fun! s:ctx.Mes(case, actual) "{{{
    let [desc, inp, outp] = a:case
    let mes = join([
          \ "case: '" . desc . "'",
          \ '       input: ' . string(inp),
          \ '    expected: ' . string(outp),
          \ '      actual: ' . string(a:actual),
          \ ], "\n")
    return mes
endfunction "}}}

fun! xpsnip#unittest#Runall(ptn) abort "{{{
    echo 'Unittest: autoload/xpsnip/ut/' . a:ptn . '.vim'
    try
        exe 'runtime!' 'autoload/xpsnip/ut/' . a:ptn . '.vim'
        echo "All tests passed"
    catch /.*/
        " bla
    endtry
endfunction "}}}

fun! xpsnip#unittest#RunMe( sid, fn ) abort "{{{

    echo "Test: " . string(a:fn)

    let ff = s:GetTestFuncs( a:sid )
    let funcnames = keys( ff )
    sort( funcnames )

    for funcname in funcnames
        if funcname !~ '\V\<Test'
            continue
        endif

        echo 'Case: ' . funcname
        let Func = ff[ funcname ]

        try
            call Func( s:ctx )
        catch /.*/
            echo "    " a:fn
            echo "    " funcname
            echo "    " v:throwpoint
            echo "Failure" v:exception
            throw "F"
        endtry
    endfor

endfunction "}}}

fun! s:GetTestFuncs( sid ) abort "{{{

    let clz = {}

    let funcs = split( xpsnip#util#GetCmdOutput( 'silent function /' . a:sid ), "\n" )
    call map( funcs, 'matchstr( v:val, "' . a:sid . '\\zs.*\\ze(" )' )

    for name in funcs
        if name !~ '\V\^_'
            let clz[ name ] = function( '<SNR>' . a:sid . name )
        endif
    endfor

    return clz

endfunction "}}}

let &cpo = s:oldcpo
