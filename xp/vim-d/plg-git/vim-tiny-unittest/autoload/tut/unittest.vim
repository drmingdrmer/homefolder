if exists("g:__autoload_tut_unittest__")
    finish
endif
let g:__autoload_tut_unittest__ = 1

let s:oldcpo = &cpo
set cpo-=< cpo+=B

let g:tut_unittest_let_sid = 'nmap tutsid <SID>|let s:sid=matchstr(maparg("tutsid"), "\\d\\+_")| nunmap tutsid'
let tut#unittest#run = 'exe g:tut_unittest_let_sid | call tut#unittest#RunCasesInFile(s:sid, expand("<sfile>"))'

let s:ctx = {}

fun! s:ctx.Fail( mes ) abort "{{{
    throw a:mes
endfunction "}}}
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
fun! s:ctx.Mes(case, actual) abort "{{{
    let [desc, inp, outp] = a:case
    let mes = join([
          \ "case: '" . desc . "'",
          \ '       input: ' . string(inp),
          \ '    expected: ' . string(outp),
          \ '      actual: ' . string(a:actual),
          \ ], "\n")
    return mes
endfunction "}}}

fun! tut#unittest#RunFnmatch(ptn) abort "{{{
    echo 'Unittest: ' . a:ptn . '.vim'
    try
        exe 'runtime!' a:ptn . '.vim'
        echo "All tests passed"
        return 1
    catch /.*/
        return 0
    endtry
endfunction "}}}
fun! tut#unittest#RunCasesInFile( sid, fn ) abort "{{{

    echo "Test: " . string(a:fn)

    let ff = s:loadTestFunctions( a:sid )
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

fun! s:loadTestFunctions( sid ) abort "{{{

    let clz = {}

    let funcs = split( s:getCmdOutput( 'silent function /' . a:sid ), "\n" )
    call map( funcs, 'matchstr( v:val, "' . a:sid . '\\zs.*\\ze(" )' )

    for name in funcs
        if name !~ '\V\^_'
            let clz[ name ] = function( '<SNR>' . a:sid . name )
        endif
    endfor

    return clz

endfunction "}}}
fun! s:getCmdOutput( cmd ) abort "{{{
    let a = ""

    redir => a
    exe a:cmd
    redir END

    return a
endfunction "}}}

let &cpo = s:oldcpo
