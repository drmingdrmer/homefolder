if exists( "g:__GITCOMMIT_fds6sfdsfsf78d8dfd__" )
    finish
endif
let g:__GITCOMMIT_fds6sfdsfsf78d8dfd__ = 1

fun! s:CompleteFixup() "{{{
    let cmd = 'git log --format="%s" -n100'
    let subjects = system( cmd )

    let lines = split( subjects, '\V\n' )
    let matches = []

    let line = ""
    for line in lines
        let line = substitute( line, '\V\s\*\$', '', '' )
        if line !~ '\V\^\(fixup!\|squash!\) '
            call add( matches, line )
        endif
    endfor

    call complete( col( "." ), matches )
    return ''

endfunction "}}}

" Helper to add fixup( or squash ) commit message.
" See: git help rebase --autosquash
nnoremap <buffer> F Sfixup! <C-r>=<SID>CompleteFixup()<CR>
