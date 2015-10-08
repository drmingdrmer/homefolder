fun! s:format_astyle() "{{{

    if ! executable('astyle')
        echom 'astyle not found'
        return
    endif

    " load .astylerc from cwd
    let rcfn = ".astylerc"
    if filereadable(rcfn)
        let lines = readfile(rcfn)
    elseif filereadable($HOME . '/.astylerc')
        " let astyle to find a rc file
        let lines = []
    else
        let lines = [
              \ "--mode=c",
              \ "--style=attach",
              \ "--unpad-paren",
              \ "--pad-oper",
              \ "--pad-paren-in",
              \ "--pad-header",
              \ "--convert-tabs",
              \ "--indent=spaces=4",
              \ "--add-brackets",
              \ "--align-pointer=name",
              \ ]
    endif

    call filter(lines, 'v:val !~ "\\v^#"')
    call filter(lines, 'v:val !~ "\\v^ *$"')

    " support long options without leading '--'
    let ls = []
    for line in lines
        if line !~ '\v^-'
            let line = '--' . line
        endif
        let ls += [line]
    endfor

    let arg = join(ls, " ")

    exe '%!astyle' arg
endfunction "}}}

nnoremap <buffer> <Plug>format:format_file :call <SID>format_astyle()<CR>
