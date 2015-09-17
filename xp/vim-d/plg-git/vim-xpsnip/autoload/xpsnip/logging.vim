if exists("g:__autoload_xpsnip_logging__")
    finish
endif
let g:__autoload_xpsnip_logging__ = 1

let s:oldcpo = &cpo
set cpo-=<
set cpo+=B

exe xpsnip#util#let_sid

let s:logLocation = ''

call xpsnip#util#Default('conf_debug', 0)
call xpsnip#util#Default('conf_assert', 0)
call xpsnip#util#Default('conf_log_path', '')

fun! xpsnip#logging#Init() abort "{{{
    call xpsnip#logging#DefineLoggingCommands()
    call xpsnip#logging#MakeLogPath()
endfunction "}}}
fun! xpsnip#logging#DefineLoggingCommands() abort "{{{
    let p = 'xpsnip_'
    if g:{p}conf_debug == 1
        com! -nargs=* XPsnipDD call xpsnip#logging#Log('Debug', eval('['.<q-args>.']'))
        com! -nargs=* XPsnipDwarn call xpsnip#logging#Log('Warn', eval('['.<q-args>.']'))
        com! -nargs=* XPsnipDerr call xpsnip#logging#Log('Error', eval('['.<q-args>.']'))
    else
        com! -nargs=* XPsnipDD
        com! -nargs=* XPsnipDwarn
        com! -nargs=* XPsnipDerr
    endif

    if g:{p}conf_assert == 1
        com! -nargs=* XPsnipAssert call xpsnip#logging#Assert(<q-args>, eval('['.<q-args>.']'))
        " com! -nargs=* XPsnipAssert echo string(eval('['.<q-args>.']'))
    else
        com! -nargs=* XPsnipAssert
    endif
endfunction "}}}
fun! xpsnip#logging#Assert( ass, args ) abort "{{{
    let shouldBeTrue = a:args[0]
    if ! shouldBeTrue
        throw a:ass
    end
endfunction "}}}
fun! xpsnip#logging#Log(level, messages) abort "{{{

    if s:logLocation == ''
        return
    end

    " call stack printing
    try
        throw ''
    catch /.*/
        let stack = matchstr( v:throwpoint, 'function\s\+\zs.\{-}\ze\.\.\%(Fatal\|Error\|Warn\|Info\|Log\|Debug\).*' )
        let stack = substitute( stack, '<SNR>\d\+_', '', 'g' )
    endtry

    exe 'redir! >> '.s:logLocation

    silent echom a:level . ':::' . stack . ' cursor at=' . string( [ line("."), col(".") ] )

    for msg in a:messages
        let l = split(';' . msg . ';', "\n")
        let l[0] = l[0][1:]
        let l[ -1 ] = l[ -1 ][ :-2 ]
        for v in l
            silent! echom v
        endfor
    endfor
    redir END

endfunction "}}}
fun! xpsnip#logging#MakeLogPath() abort "{{{

    let p = 'xpsnip_'

    let path = g:{p}conf_log_path
    if path == ''
        let s:logLocation = ''
    else
        let path = substitute( path, '\V\^~/', $HOME . '/', '' )
        let s:logLocation = path
        call delete(s:logLocation)
    endif
endfunction "}}}

let &cpo = s:oldcpo
