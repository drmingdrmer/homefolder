let xpsnip#once#init = 'if xpsnip#once#SetAndGetLoaded(expand("<sfile>")) | finish | endif'

call xpsnip#util#Default('i_loaded', {})

fun! xpsnip#once#SetAndGetLoaded( fn ) abort "{{{

    let fn = resolve(fnamemodify( a:fn, ':p' ))
    let fn = s:Norm(fn)

    let _rtps = split(&runtimepath, ',')
    let rtps = []
    for p in _rtps
        let p = resolve(fnamemodify( p, ':p' ))
        let p = s:Norm(p) . '/'
        let rtps += [p]
    endfor

    " Sort descendingly thus it tries to match longer rtp first.
    " If file path matches both inner rtp and outer rpt, prefer inner one.
    call sort(rtps)
    call reverse(rtps)

    for p in rtps

        let pref = fn[ 0 : len(p) - 1 ]

        if pref == p

            let relpath = fn[ len(pref) : ]

            if has_key(g:xpsnip_i_loaded, relpath)
                return 1
            else
                let g:xpsnip_i_loaded[relpath] = 1
                return 0
            endif
        endif
    endfor

    echoerr a:fn . ' not found in any one of &runtimepath'
    return 0

endfunction "}}}

fun! s:Norm(path) abort "{{{

    let path = a:path
    let path = substitute(path, '\V\\', '/', 'g')

    " trailing slash
    let path = substitute( path, '\V/\*\$', '', 'g' )

    " multi slash
    let path = substitute( path, '\V//\*', '/', 'g' )

    while 1
        " remove ref to parent
        let p0 = path
        let path = substitute( path, '\V/\[^/]\+/..', '', 'g' )
        if p0 == path
            break
        endif
    endwhile

    return path
endfunction "}}}

exec xpsnip#once#init
